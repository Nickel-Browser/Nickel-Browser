# Testing Nickel Browser

## Unit Tests
Run the following command in the build directory:
`autoninja -C out/Release nickel_unit_tests && ./out/Release/nickel_unit_tests`

## Manual Verification

### Ad Blocking
1. Visit `https://www.nytimes.com`.
2. Open DevTools > Network.
3. Verify that tracker requests are blocked.

### Tor Integration
1. Open a Tor tab.
2. Visit `https://check.torproject.org`.
3. Verify that the page says "Congratulations".

### Fingerprinting
1. Visit `https://browserleaks.com/canvas`.
2. Note the fingerprint.
3. Restart the browser and visit the site again.
4. Verify the fingerprint has changed.
