#!/usr/bin/env node

/**
 * OG Image Generator for Social Media
 * Creates a professional 1200x630px Open Graph image for social sharing
 * Install: npm install canvas sharp --save-dev
 */

const canvas = require('canvas');
const fs = require('fs');
const path = require('path');

const width = 1200;
const height = 630;

// Create canvas
const cvs = canvas.createCanvas(width, height);
const ctx = cvs.getContext('2d');

// Background gradient
const gradient = ctx.createLinearGradient(0, 0, width, height);
gradient.addColorStop(0, '#2563eb');
gradient.addColorStop(1, '#1e40af');
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, width, height);

// Add decorative circles (glass effect)
ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
ctx.beginPath();
ctx.arc(150, 100, 150, 0, Math.PI * 2);
ctx.fill();

ctx.beginPath();
ctx.arc(1000, 500, 200, 0, Math.PI * 2);
ctx.fill();

// Main title
ctx.font = 'bold 80px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto';
ctx.fillStyle = '#ffffff';
ctx.textAlign = 'center';
ctx.textBaseline = 'middle';

// Break title into two lines if needed
ctx.fillText('mQuiz', width / 2, height / 2 - 80);

// Subtitle
ctx.font = '36px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto';
ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
ctx.fillText('Learn, Engage & Earn Rewards', width / 2, height / 2 + 40);

// Tagline
ctx.font = '24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto';
ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
ctx.fillText('The Ultimate Quiz Learning App', width / 2, height / 2 + 100);

// Save canvas
const publicDir = path.join(__dirname, '../public');
if (!fs.existsSync(publicDir)) {
    fs.mkdirSync(publicDir, { recursive: true });
}

const buffer = cvs.toBuffer('image/jpeg', { quality: 0.95 });
const outputPath = path.join(publicDir, 'og-image.jpg');
fs.writeFileSync(outputPath, buffer);

console.log(`✓ OG Image generated: ${outputPath}`);
console.log(`  Dimensions: ${width}x${height}px`);
console.log(`  Size: ${(buffer.length / 1024).toFixed(2)}KB`);
