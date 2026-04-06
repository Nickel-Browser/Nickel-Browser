// Particle animation
document.addEventListener('DOMContentLoaded', () => {
    const particles = document.getElementById('particles');
    if (particles) {
        for (let i = 0; i < 50; i++) {
            const particle = document.createElement('div');
            particle.style.cssText = `
                position: absolute;
                width: ${Math.random() * 4 + 1}px;
                height: ${Math.random() * 4 + 1}px;
                background: rgba(233, 69, 96, ${Math.random() * 0.5});
                border-radius: 50%;
                left: ${Math.random() * 100}%;
                top: ${Math.random() * 100}%;
                animation: float ${Math.random() * 10 + 5}s ease-in-out infinite;
            `;
            particles.appendChild(particle);
        }
    }
    
    // Platform detection
    const platformDiv = document.getElementById('platform-detected');
    const platform = navigator.platform.toLowerCase();
    let platformName = '';
    
    if (platform.includes('linux')) {
        platformName = '🐧 Linux detected - Download .deb or .AppImage below';
    } else if (platform.includes('mac') || platform.includes('darwin')) {
        platformName = '🍎 macOS detected - Download .dmg below';
    } else if (platform.includes('win')) {
        platformName = '🪟 Windows detected - Download .exe below';
    }
    
    if (platformName && platformDiv) {
        platformDiv.textContent = platformName;
        platformDiv.classList.add('active');
    }
});
