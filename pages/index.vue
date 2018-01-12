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
            style: 'http://localhost:8081/styles/klokantech-basic/style.json',
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
import {scaleLinear} from 'd3-scale';
import {extent} from 'd3-array';

export default {
    data () {
        let bounds = [[-76.78709599958069, 39.72080199961266], [-77.31156199998628, 39.34846299986759]];
        let requiredDocs = ['mg-small-cell/Montgomery_County_Dissolve.geojson', 'mg-small-cell/ACS.geojson', 'mg-small-cell/Towers_Rescinded.geojson'];
        requiredDocs = Promise.all(requiredDocs.map(doc => this.$axios.get(doc)));
        return {
            bounds: bounds,
            mapLoaded: (map) => {
                console.log('Executing after load');
                requiredDocs.then(docs => {
                    let mask = docs[0].data;
                    let acs = docs[1].data;
                    let proposedTowers = docs[2].data;

                    let providerScale = scaleLinear()
                    .domain(extent(acs.features.map(d => d.properties.numProviders)))
                    .range(['#eff3ff','#bdd7e7','#6baed6','#3182bd','#08519c']);

                    // map.setMaxBounds(turf.bbox(mask.features[0])); // => This limits panning to the desired area. For some reason this isn't applying uniformly, it cuts off the map briefly.
                    map.fitBounds(turf.bbox(mask.features[0]));

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
                        'fill-color': 'grey',
                        'fill-opacity': 0.70
                        }
                    });

                    map.addLayer({
                        'id': 'broadbandProviderCount',
                        'source': 'acs',
                        'type': 'fill',
                        'paint': {
                            'fill-opacity': 0.6,
                            'fill-color': [
                                    'interpolate',
                                    ['exponential', 4],
                                    ['number', ['get', 'foodstamps']],
                                    100, '#f1eef6',
                                    200, '#bdc9e1',
                                    300, '#74a9cf',
                                    400, '#045a8d'
                            ]
                        }
                    });

                    map.addLayer({
                        'id': 'broadbandProviderCount_stroke',
                        'source': 'acs',
                        'type': 'line',
                        'paint': {
                            'line-width': 0.3,
                            'line-opacity': 0.4
                        }
                    });

                    map.addLayer({
                        'id': 'proposedTowers_circle',
                        'source': 'proposedTowers',
                        'type': 'circle',
                        'paint': {
                            'circle-radius': 3,
                            'circle-color': 'yellow'
                        }
                    });    
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

<style scoped>
#map {
  width: 100%;
  height: 700px;
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
