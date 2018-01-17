<template>
    <section>
        <mapbox
        @map-load="mapLoaded"
        :accessToken='accessToken'
        :mapOptions="options">
        </mapbox>
        <div id='legend' class='legend'>
            <h4 style="margin:0px; line-height:100%;">Population density</h4>
            <small>per sq. mi</small>
            <div v-for="item in legend">
                <div style="float:left;">
                    <span class='legend-key' :style="'background-color:' + item[1] + '; width:' + item[2] + 'px;'"></span>
                </div>
            </div>
            <div>
                <div style="clear:both;" v-if="legendTicks.length > 0">
                        <span :style="'position:relative; left: 0%;'">0</span>
                        <span :style="'position:relative; left: 35%'">12,500</span>
                        <span :style="'position:relative; left: 70%'">57,000</span>
                    <!-- 
                        <span v-for="item in legendTicks">
                            <span :style="'margin-left:' + (item[1] - 20) + 'px'">{{item[0]}}</span>
                        </span>
                    -->
                </div>
            </div>
        </div>
        <small>Sources: 2015 American Community Survey, Mobilitie Inc., OpenStreetMap contributors</small>
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
            legend: [],
            legendTicks: [],
            options: {
                maxZoom: 14,
                minZoom: 9,
                style: 'https://s3.amazonaws.com/apps.publicintegrity.org/map-tiles/style.json',
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
            let fillStops = [];
            colorScheme.forEach((color, index) => {
                let currentQuantile = (index + 1) / colorScheme.length;
                fillStops.push(d3.quantile(propValues, currentQuantile));
                fillStops.push(color);
            });

            fillColorArray = fillColorArray.concat(fillStops);

            this.drawLegend(fillStops);

            map.addLayer(
                {
                    id: 'acs-' + prop,
                    source: 'acs',
                    type: 'fill',
                    paint: {
                        'fill-opacity': 0.6,
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
        addAttribution(map) {
            map.addControl(new this.$mapboxgl.AttributionControl({
                compact: true
            }));
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
            this.addAttribution(map);
        },
        mapLoaded(map) {
            // console.log('Executing after load');
            this.loadData().then(this.drawMap.bind(this, map));
        },
        drawLegend(legend) {
            for (let i = 0; i < legend.length; i = i + 2) {
                let legendItem = legend.slice(i,i+2);
                legendItem[0] = Math.round(legendItem[0] / 3.86102e-7);
                this.legend.push(legendItem);
            }
            let legendScale = d3.scaleLinear()
            .domain([0, d3.max(this.legend.map(d => d[0]))])
            .range([5, 150]);

            this.legend = this.legend.map(d => {
                d.push(legendScale(d[0]));
                return d;
            });

            this.legendTicks = [0, 0.5, 1].map((d, i) => {
                return [d, legendScale.invert(d * 100)];
            });

            console.log(this.legend);
            
            console.log(`Drawing a legend with ${this.legend.length} stops.`);
        },
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

.legend {
  width: 300px;
  background-color: #fff;
  border-radius: 3px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  font: 12px/20px 'Helvetica Neue', Arial, Helvetica, sans-serif;
  padding: 10px;
  position: absolute;
  right: 10px;
  top: 570px;
  z-index: 1;
}

.legend h4 {
  font-size: 16px;
  margin: 0 0 10px;
}

.legend p {
  margin-left: 30px;
  position: absolute;
  display: block;
  top: 0;
}

.legend-key {
  display: inline-block;
  width: 10px;
  height: 12px;
}


.legend div span {
  font-size: 12px;
  display: inline-block;
  opacity: 0.8;
}

</style>