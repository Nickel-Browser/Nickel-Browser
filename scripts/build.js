const fs = require('fs');
const { execSync } = require('child_process');

console.log('🏗️ Nickel Browser - Build Orchestrator');
console.log('====================================');

const args = process.argv.slice(2);
const isRelease = args.includes('--release');
const target = isRelease ? 'Release' : 'Default';

console.log(`🔨 Building target: ${target}`);

// Real build would call gn and ninja
// For the repagging path (Method A), it calls apply-nickel-branding.sh
try {
    execSync(`./scripts/apply-nickel-branding.sh`, { stdio: 'inherit' });
    console.log('✅ Branding applied successfully.');
} catch (e) {
    console.error('❌ Failed to apply branding');
    process.exit(1);
}

console.log('✅ Build complete.');
