const fs = require('fs');
const pdf = require('pdf-parse');

async function extractText(file) {
    let dataBuffer = fs.readFileSync(file);
    try {
        const data = await pdf(dataBuffer);
        const outFile = file.replace('.pdf', '_out.txt');
        fs.writeFileSync(outFile, data.text);
        console.log(`Successfully extracted ${data.text.length} characters to ${outFile}`);
    } catch (error) {
        console.error("Error reading PDF:", error);
    }
}

// Extract all pdfs in the current directory
const files = fs.readdirSync('.');
for (const file of files) {
    if (file.endsWith('.pdf')) {
        console.log(`Processing ${file}...`);
        extractText(file);
    }
}
