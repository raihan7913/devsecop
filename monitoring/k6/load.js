import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },   // ramp to 20 VUs
    { duration: '2m',  target: 100 },  // hold 100 VUs
    { duration: '1m',  target: 300 },  // peak 300 VUs (flood)
    { duration: '2m',  target: 0 }     // ramp down
  ],
  thresholds: {
    'http_req_failed': ['rate<0.01'],    // abort criteria: >1% error
    'http_req_duration': ['p(95)<1000']    // p(95) < 1000ms
  },
  noConnectionReuse: false
};

export default function () {
  const res = http.get('http://host.docker.internal:3000/');
  check(res, { 'status 200': r => r.status === 200 });
  sleep(1);
}