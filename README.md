# dnsracer 🏁

A fast, clean DNS resolver benchmark tool that tests and ranks public DNS servers by response time from your location.

## Features

- 🚀 **Fast Testing** - Benchmarks 8 major public DNS resolvers
- 📊 **Clear Rankings** - Color-coded results with top 3 highlighted
- 🌍 **Global Coverage** - Tests major providers: Cloudflare, Google, Quad9, OpenDNS, and more
- 🎯 **Smart Detection** - Early abort on unreachable servers
- 🐛 **Debug Mode** - Detailed logging with `--debug` flag
- 💻 **Cross-platform** - Works on Linux, macOS, and WSL

## Quick Start

```bash
# Download and run
curl -O https://raw.githubusercontent.com/FabianBeiner/dnsracer/edit/main/dnsracer.sh
chmod +x dnsracer.sh
./dnsracer.sh
```

## Requirements

- `dig` (from dnsutils/bind-tools)
- `bc` (basic calculator)
- `curl`

**Install on Debian/Ubuntu:**
```bash
sudo apt install dnsutils bc curl
```

**Install on macOS:**
```bash
brew install bind
```

## Example Output

```
════════════════════════════════════════════════════════════════════════
                         FINAL RANKINGS
════════════════════════════════════════════════════════════════════════
Rank   Resolver             IP Address(es)                       Avg Time    Success Rate
────────────────────────────────────────────────────────────────────────
1.     Cloudflare           1.1.1.1, 1.0.0.1                      3.71 ms    100%
2.     Google               8.8.8.8, 8.8.4.4                      6.42 ms    100%
3.     Quad9                9.9.9.9, 149.112.112.112              8.15 ms    100%
```

## Usage

```bash
# Basic usage
./dnsracer.sh

# Enable debug logging
./dnsracer.sh --debug
```

## Tested DNS Resolvers

| Provider | Primary IP | Secondary IP | Notes |
|----------|------------|--------------|-------|
| Cloudflare | 1.1.1.1 | 1.0.0.1 | Fast, privacy-focused |
| Google | 8.8.8.8 | 8.8.4.4 | Reliable, global coverage |
| Quad9 | 9.9.9.9 | 149.112.112.112 | Security-focused |
| OpenDNS | 208.67.222.222 | 208.67.220.220 | Optional filtering |
| DNS.SB | 185.222.222.222 | 45.11.45.11 | No-logging |
| AdGuard | 94.140.14.14 | 94.140.15.15 | Ad-blocking |
| CleanBrowsing | 185.228.168.9 | 185.228.168.10 | Family-safe |
| Comodo | 8.26.56.26 | 8.20.247.20 | Security-focused |

## Test Domains

The script tests against these domains:
- google.com
- cloudflare.com
- github.com
- wikipedia.org
- heise.de
- spiegel.de
- deutsche-telekom.de

Each domain is queried 3 times to calculate an average response time.

## Tips

- **Lower is better** - Response times under 20ms are excellent
- **Geographic proximity matters** - Servers closer to you will typically be faster
- **Consistent results** - Run multiple times to account for network variability
- **Port 53 UDP** - Ensure outbound UDP traffic on port 53 is not blocked

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions welcome! Feel free to:
- Improve test methodology
- Enhance output formatting
- Fix bugs

## Author

Created by Fabian Beiner

---

**Note:** This tool measures DNS resolution speed from your specific location. Results will vary based on your geographic location and network conditions.
