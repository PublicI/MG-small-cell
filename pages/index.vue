<template>
    <section>
        <mapbox
        @map-load="mapLoaded"
        :accessToken='accessToken'
        :mapOptions="options" />
    </section>
</template>

<script>
import Mapbox from 'mapbox-gl-vue';
import * as turf from '@turf/turf';
import * as d3 from 'd3';
import * as colorScale from 'd3-scale-chromatic';

export default {
    data() {
        return {
            accessToken: 'asdfsdf',
            options: {
                style: 'http://map-api.time-sandbox.com/styles/positron.json',
                center: [-77.20809249981897, 39.144234494486],
                /*
                bounds: [
                    [-76.78709599958069, 39.72080199961266],
                    [-77.31156199998628, 39.34846299986759]
                ], */
                height: 100,
                zoom: 9.8
            },
            requiredDocs: [
                'Montgomery_County_Dissolve.geojson',
                'ACS.geojson',
                'Mobilitie.geojson'
            ]
        };
    },
    methods: {
        loadData() {
            return Promise.all(this.requiredDocs.map(this.$axios.get));
        },
        drawData(map, acs, prop) {
            let propValues = acs.features
                .map(d => d.properties[prop])
                .sort(d3.ascending);

            let colorScheme = colorScale.schemeGnBu[7];
            let fillColorArray = [
                'interpolate',
                ['linear'],
                ['number', ['get', prop]]
            ];

            // console.log(map.getStyle().layers);

            colorScheme.forEach((color, index) => {
                let currentQuantile = (index + 1) / colorScheme.length;
                fillColorArray.push(d3.quantile(propValues, currentQuantile));
                fillColorArray.push(color);
            });

            map.addLayer(
                {
                    id: 'acs-' + prop,
                    source: 'acs',
                    type: 'fill',
                    paint: {
                        'fill-opacity': 0.8,
                        'fill-color': fillColorArray
                    }
                },
                'place_other'
            );

            map.addLayer({
                id: 'proposedTowers_circle',
                source: 'proposedTowers',
                type: 'circle',
                paint: {
                    'circle-radius': 2.9,
                    'circle-color': 'rgb(250, 98, 150)',
                    'circle-opacity': 1,
                    'circle-blur': 0,
                    'circle-stroke-width': 0.6,
                    'circle-stroke-color': '#FFF'
                }
            });
        },
        drawMap(map, docs) {
            let mask = docs[0].data;
            let acs = docs[1].data;
            let proposedTowers = docs[2].data;

            // map.setMaxBounds(turf.bbox(mask.features[0])); // => This limits panning to the desired area. For some reason this isn't applying uniformly, it cuts off the map briefly.
            map.fitBounds(turf.bbox(mask.features[0]), {
                animate: false
            });

            map.dragRotate.disable();
            map.touchZoomRotate.disableRotation();

            // This function will create a low opacity mask around Montgomery County to communicate that they can't access the rest of the map;
            map.addSource('mask', {
                type: 'geojson',
                data: turf.mask(mask.features[0])
            });

            map.addSource('outline', {
                type: 'geojson',
                data: mask.features[0]
            });

            // This function will add our data layer as a geojson source.
            map.addSource('acs', {
                type: 'geojson',
                data: acs
            });

            // This function will add our data layer as a geojson source.
            map.addSource('proposedTowers', {
                type: 'geojson',
                data: proposedTowers
            });

            map.addLayer({
                id: 'zmask',
                source: 'mask',
                type: 'fill',
                paint: {
                    'fill-color': 'white',
                    'fill-opacity': 0.5
                }
            });

            // adds a gray outline around the county
            map.addLayer({
                id: 'zoutline',
                source: 'outline',
                type: 'line',
                paint: {
                    'line-color': 'rgb(200,200,200)',
                }
            });

            this.drawData(map, acs, 'popDensity');
        },
        mapLoaded(map) {
            // console.log('Executing after load');
            this.loadData().then(this.drawMap.bind(this, map));
        }
    },
    head() {
        return {
            title: 'Montgomery County small cell applications'
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
#map .mapboxgl-ctrl-group .mapboxgl-ctrl-compass {
    display: none;
}
</style>
