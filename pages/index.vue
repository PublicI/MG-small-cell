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
            zoom: 9,
            //maxBounds: bounds.reverse()
        }">
    </mapbox>
    </section>
</template>

<script>
import Mapbox from 'mapbox-gl-vue';
import axios from 'axios';
import * as turf from '@turf/turf';

export default {
    data () {
        let bounds = [[-76.78709599958069, 39.72080199961266], [-77.31156199998628, 39.34846299986759]];
        let mask = axios.get('/mg-small-cell/Montgomery_County_Dissolve.geojson');
        return {
            bounds: bounds,
            mapLoaded: (map) => {
                map.fitBounds(bounds);
                console.log('TEST');
                mask.then(d => {
                    // This function will create a low opacity mask around Montgomery County to communicate that they can't access the rest of the map;
                    map.addSource('mask', {
                        'type': 'geojson',
                        'data': turf.mask(d.data.features[0])
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
                });
            }
        };
    },
    async asyncData ({ app, error }) {
        let data = await app.$axios.$get('/api/examples');
        return {
            examples: data,
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
  height: 500px;
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
