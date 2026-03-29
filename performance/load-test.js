import http from 'k6/http';
import { check, sleep } from 'k6';

const baseUrl = __ENV.BASE_URL || 'http://waf:8080';
const hostHeader = __ENV.HOST_HEADER || '';
const sleepSeconds = Number(__ENV.SLEEP_SECONDS || '0.1');

export const options = {
  vus: Number(__ENV.VUS || '10'),
  duration: __ENV.DURATION || '20s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
  },
};

export default function () {
  const params = hostHeader
    ? { headers: { Host: hostHeader } }
    : {};

  const response = http.get(`${baseUrl}/`, params);

  check(response, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(sleepSeconds);
}
