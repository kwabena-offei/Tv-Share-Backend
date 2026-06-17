const fs = require('fs');
const path = require('path');

function loadRequiredKeys() {
  const envExamplePath = path.join(__dirname, '..', 'env.example');
  if (!fs.existsSync(envExamplePath)) {
    return [];
  }
  const content = fs.readFileSync(envExamplePath, 'utf8');
  return content
    .split('\n')
    .map(line => line.trim())
    .filter(line => line && !line.startsWith('#'))
    .map(line => line.split('=')[0]);
}

function checkEnv(keys) {
  const missing = keys.filter(key => !process.env[key]);
  if (missing.length) {
    console.error('Missing required environment variables:');
    missing.forEach(key => console.error(`- ${key}`));
    process.exit(1);
  }
}

if (require.main === module) {
  const required = loadRequiredKeys();
  checkEnv(required);
  console.log('All required environment variables are set.');
}
