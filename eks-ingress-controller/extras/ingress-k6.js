import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

export default function () {
  const url =
    'http://linuxtips-eks-kong-4f969004415f09a8.elb.us-east-1.amazonaws.com/system';

  const params = {
    headers: {
      Host: 'chip.msfidelis.com.br',
    },
  };

  const response = http.get(url, params);

  check(response, {
    'status is 200': (r) => r.status === 200,
  });
}