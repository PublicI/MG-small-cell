<template>
    <section class="container">
        <link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.43.0/mapbox-gl.css' rel='stylesheet' />
        <h1 class="title">
            Small Cell Applications | Montgomery County
        </h1>
        <mapbox
        @map-load="mapLoaded"
        access-token='asdfsdf'
        :map-options="{
            style: 'http://map-api.time-sandbox.com/styles/positron.json',
            center: [-77.2405, 39.1547],
            height: 100,
            zoom: 6,
            //maxBounds: bounds.reverse()
        }">
    </mapbox>
    </section>
</template>

<script>
import Mapbox from 'mapbox-gl-vue';
import * as turf from '@turf/turf';
import * as d3 from 'd3';
import * as colorScale from 'd3-scale-chromatic';

export default {
    data () {
        let bounds = [[-76.78709599958069, 39.72080199961266], [-77.31156199998628, 39.34846299986759]];
        let requiredDocs = ['mg-small-cell/Montgomery_County_Dissolve.geojson', 'mg-small-cell/ACS.geojson', 'mg-small-cell/Mobilitie.geojson'];
        requiredDocs = Promise.all(requiredDocs.map(doc => this.$axios.get(doc)));
        return {
            bounds: bounds,
            mapLoaded: (map) => {
                console.log('Executing after load');
                requiredDocs.then(docs => {
                    let mask = docs[0].data;
                    let acs = docs[1].data;
                    let proposedTowers = docs[2].data;

                    // map.setMaxBounds(turf.bbox(mask.features[0])); // => This limits panning to the desired area. For some reason this isn't applying uniformly, it cuts off the map briefly.
                    map.fitBounds(turf.bbox(mask.features[0]), {
                        animate: false
                    });

                    // This function will create a low opacity mask around Montgomery County to communicate that they can't access the rest of the map;
                    map.addSource('mask', {
                        'type': 'geojson',
                        'data': turf.mask(mask.features[0])
                    });

                    // This function will add our data layer as a geojson source.
                    map.addSource('acs', {
                        'type': 'geojson',
                        'data': acs
                    });

                    // This function will add our data layer as a geojson source.
                    map.addSource('proposedTowers', {
                        'type': 'geojson',
                        'data': proposedTowers
                    });

                    map.addLayer({
                        'id': 'zmask',
                        'source': 'mask',
                        'type': 'fill',
                        'paint': {
                            'fill-color': '#CCC',
                            'fill-opacity': 0.6
                        }
                    });

                    function drawMap(prop) {
                        let propValues = acs.features.map(d => d.properties[prop]).sort(d3.ascending);

                        let colorScheme = colorScale.schemeGnBu[7];
                        let fillColorArray = [
                            'interpolate',
                            ['linear'],
                            ['number', ['get', prop]]
                        ];

                        console.log(map.getStyle().layers);

                        colorScheme.forEach((color, index) => {
                            let currentQuantile = (index + 1) / colorScheme.length;
                            fillColorArray.push(d3.quantile(propValues, currentQuantile));
                            fillColorArray.push(color);
                        });
                        
                        map.addLayer({
                            'id': 'broadbandProviderCount',
                            'source': 'acs',
                            'type': 'fill',
                            'paint': {
                                'fill-opacity': 0.8,
                                'fill-color': fillColorArray
                            }
                        }, 'place_other');

                        map.addLayer({
                            'id': 'proposedTowers_circle',
                            'source': 'proposedTowers',
                            'type': 'circle',
                            'paint': {
                                'circle-radius': 2.9,
                                'circle-color': 'rgb(250, 98, 150)',
                                'circle-opacity': 1,
                                'circle-blur': 0,
                                'circle-stroke-width': 0.6,
                                'circle-stroke-color': '#FFF'
                            }
                        });
                    }

                    drawMap('popDensity');

                    /* map.addLayer({
                        'id': 'broadbandProviderCount_stroke',
                        'source': 'acs',
                        'type': 'line',
                        'paint': {
                            'line-width': 0,
                            'line-opacity': 0.2
                        }
                    }); */
                });
            }
        };
    },
    head () {
        return {
            title: 'examples'
        };
    },
    components: { Mapbox }
};
</script>

<style>
#map {
  width: 100%;
  height: 700px;
}

#map > div.mapboxgl-control-container > div.mapboxgl-ctrl-top-right > div > button.mapboxgl-ctrl-icon.mapboxgl-ctrl-compass {
    display: none;
}

.title {
    margin: 30px 0;
}
.examples {
    list-style: none;
    margin: 0;
    padding: 0;
}
.example {
    margin: 10px 0;
}
</style>
