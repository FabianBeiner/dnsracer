# dnsracer 🏁

A fast, clean DNS resolver benchmark tool that tests and ranks public DNS servers by response time from your location.

## Features

- 🚀 **Fast Testing** - Benchmarks 8+ major public DNS resolvers (IPv4 + IPv6)
- 📊 **Clear Rankings** - Color-coded results with top 3 highlighted
- 🌐 **IPv6 Support** - Auto-detects and tests IPv6 DNS servers when available
- 💡 **Smart Recommendations** - Suggests optimal primary/secondary mix across different providers
- 🌍 **Global Coverage** - Tests major providers: Cloudflare, Google, Quad9, OpenDNS, and more
- 🎯 **Smart Detection** - Early abort on unreachable servers
- 🐛 **Debug Mode** - Detailed logging with `--debug` flag
- 💻 **Cross-platform** - Works on Linux, macOS, and WSL

## Quick Start

```bash
# Download and run
curl -O https://raw.githubusercontent.com/FabianBeiner/dnsracer/refs/heads/main/dnsracer.sh
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
4.     Cloudflare-v6        2606:4700:4700::1111, 2606:...        9.20 ms    100%

Recommended Configuration (Best Mix):
────────────────────────────────────────────────────────────────────────
 Primary:   1.1.1.1
            (Cloudflare - 3.71 ms)
 Secondary: 8.8.8.8
            (Google - 6.42 ms)

 This configuration provides redundancy across different providers
```

## Usage

```bash
# Basic usage
./dnsracer.sh

# Enable debug logging
./dnsracer.sh --debug
```

## Tested DNS Resolvers

### IPv4 Resolvers
| Provider | Primary IP | Secondary IP | Notes |
|----------|------------|--------------|-------|
| Cloudflare | 1.1.1.1 | 1.0.0.1 | Fast, privacy-focused |
| Google | 8.8.8.8 | 8.8.4.4 | Reliable, global coverage |
| Quad9 | 9.9.9.9 | 149.112.112.112 | Security-focused |
| OpenDNS | 208.67.222.222 | 208.67.220.220 | Optional filtering |
| DNS.SB | 185.222.222.222 | 45.11.45.11 | No-logging |
| AdGuard | 94.140.14.14 | 94.140.15.15 | Ad-blocking |
| CleanBrowsing | 185.228.168.9 | 185.228.168.10 | Security filtering |
| Comodo | 8.26.56.26 | 8.20.247.20 | Security-focused |

### IPv6 Resolvers (tested automatically when IPv6 is available)
| Provider | Primary IPv6 | Secondary IPv6 |
|----------|--------------|----------------|
| Cloudflare | 2606:4700:4700::1111 | 2606:4700:4700::1001 |
| Google | 2001:4860:4860::8888 | 2001:4860:4860::8844 |
| Quad9 | 2620:fe::fe | 2620:fe::9 |
| OpenDNS | 2620:119:35::35 | 2620:119:53::53 |

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

## Smart Recommendations

The tool analyzes results and recommends the optimal DNS configuration:
- **Primary DNS**: Fastest resolver overall
- **Secondary DNS**: Fastest resolver from a *different* provider

This approach provides:
- ✅ Maximum speed for both primary and fallback
- ✅ Provider redundancy (no single point of failure)
- ✅ Protocol diversity (may mix IPv4 and IPv6)

## Tips

- **Lower is better** - Response times under 20ms are excellent
- **Geographic proximity matters** - Servers closer to you will typically be faster
- **Provider diversity** - Using different providers for primary/secondary increases reliability
- **IPv6 can be faster** - Sometimes IPv6 routes are more direct than IPv4
- **Consistent results** - Run multiple times to account for network variability
- **Port 53 UDP** - Ensure outbound UDP traffic on port 53 is not blocked

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions welcome! Feel free to:
- Add more DNS providers
- Improve test methodology
- Enhance output formatting
- Fix bugs

## Author

Created by Fabian Beiner

---

**Note:** This tool measures DNS resolution speed from your specific location. Results will vary based on your geographic location and network conditions.
