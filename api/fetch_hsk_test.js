const https = require('https');
const fs = require('fs');

const url = 'https://raw.githubusercontent.com/clem109/hsk-vocabulary/master/hsk1.json';

https.get(url, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        try {
            const data = JSON.parse(body);
            console.log('Total words:', data.length);
            console.log('Sample word:', JSON.stringify(data[0], null, 2));
            fs.writeFileSync('sample_hsk1.json', JSON.stringify(data, null, 2));
        } catch (e) {
            console.error(e);
        }
    });
});
