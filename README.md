# dnsracer 🏁

A fast, clean DNS resolver benchmark tool that tests and ranks public DNS servers by response time from your location.

## Features

- 🚀 **Fast Testing** - Benchmarks 14+ major public DNS resolvers (IPv4 + IPv6)
- 📊 **Clear Rankings** - Color-coded results with top 3 highlighted
- 🌐 **IPv6 Support** - Auto-detects and tests IPv6 DNS servers when available
- 💡 **Smart Recommendations** - Suggests optimal primary/secondary mix across different providers
- 🌍 **Global + European Coverage** - Tests major global providers plus privacy-focused European resolvers
- 🔒 **Privacy-Focused Resolvers** - Includes FFMUC, dnsforge, Digitalcourage, UncensoredDNS, and more
- 🎯 **Smart Detection** - Early abort on unreachable servers
- 🖥️ **Current DNS Display** - Shows your currently configured DNS servers
- 📋 **Verbose Mode** - Optional per-query detail with `--verbose`
- 🐛 **Debug Mode** - Detailed logging with `--debug` flag
- 💻 **Cross-platform** - Works on Linux, macOS, and WSL
- 📜 **Scrollback Friendly** - Preserves terminal scrollback history

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

## Usage

```bash
# Basic usage (compact output)
./dnsracer.sh

# Show per-query results (detailed output)
./dnsracer.sh --verbose

# Show help screen with all resolvers and options
./dnsracer.sh --help

# Enable debug logging
./dnsracer.sh --debug
```

### Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--help` | `-h` | Show help screen with resolver list and exit |
| `--verbose` | `-v` | Show per-query results (detailed output) |
| `--debug` | | Enable debug logging to `dnsracer-debug.log` |

### Default vs Verbose Output

**Default** (compact) — shows only the summary per resolver:
```
→ Cloudflare (1.1.1.1 | 1.0.0.1)
  Average: 3.71 ms  •  27/27 successful (100%)  •  ✓ Excellent
```

**Verbose** (`--verbose`) — shows every individual query result:
```
→ Cloudflare (1.1.1.1 | 1.0.0.1)
  cloudflare.com          4 ms
  cloudflare.com          3 ms
  cloudflare.com          4 ms
  akamai.com              3 ms
  ...
  Average: 3.71 ms  •  27/27 successful (100%)  •  ✓ Excellent
```

## Example Output

```
════════════════════════════════════════════════════════════════════════
 Testing 14 resolvers • 9 domains × 3 queries each
 IPv6 not available - testing IPv4 resolvers only
 Early abort after 2 consecutive failures
════════════════════════════════════════════════════════════════════════

 IPv4: 192.168.1.100 (public: 203.0.113.1)
 DNS:  192.168.1.1

→ Cloudflare (1.1.1.1 | 1.0.0.1)
  Average: 3.71 ms  •  27/27 successful (100%)  •  ✓ Excellent

→ Google (8.8.8.8 | 8.8.4.4)
  Average: 6.42 ms  •  27/27 successful (100%)  •  ✓ Excellent
...

════════════════════════════════════════════════════════════════════════
                         FINAL RANKINGS
════════════════════════════════════════════════════════════════════════

Rank   Resolver             IP Address(es)                       Avg Time    Success Rate
────────────────────────────────────────────────────────────────────────
1.     Cloudflare           1.1.1.1, 1.0.0.1                      3.71 ms    100%
2.     Google               8.8.8.8, 8.8.4.4                      6.42 ms    100%
3.     Quad9                9.9.9.9, 149.112.112.112              8.15 ms    100%

Recommended IPv4 Configuration (Best Mix):
────────────────────────────────────────────────────────────────────────
 Primary:   1.1.1.1
            (Cloudflare - 3.71 ms)
 Secondary: 8.8.8.8
            (Google - 6.42 ms)

 These configurations provide redundancy across different providers
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
| CleanBrowsing | 185.228.168.9 | 185.228.169.9 | Security filtering |
| Comodo | 8.26.56.26 | 8.20.247.20 | Security-focused |
| FFMUC | 185.150.99.255 | 5.1.66.255 | Freifunk Munich, community-run |
| dnsforge | 49.12.67.122 | 91.99.154.175 | Ad-blocking (dnsforge.de) |
| Digitalcourage | 5.9.164.112 | — | Privacy-focused, Germany |
| Dig.Gesellschaft | 185.95.218.42 | 185.95.218.43 | Swiss digital society |
| UncensoredDNS | 91.239.100.100 | 89.233.43.71 | Censurfridns, Denmark |
| dismail | 116.203.32.217 | 159.69.114.157 | Privacy-focused (dismail.de) |

### IPv6 Resolvers (tested automatically when IPv6 is available)
| Provider | Primary IPv6 | Secondary IPv6 |
|----------|--------------|----------------|
| Cloudflare | 2606:4700:4700::1111 | 2606:4700:4700::1001 |
| Google | 2001:4860:4860::8888 | 2001:4860:4860::8844 |
| Quad9 | 2620:fe::fe | 2620:fe::9 |
| OpenDNS | 2620:119:35::35 | 2620:119:53::53 |
| DNS.SB | 2a09:: | 2a11:: |
| AdGuard | 2a10:50c0::ad1:ff | 2a10:50c0::ad2:ff |
| CleanBrowsing | 2a0d:2a00:1::2 | 2a0d:2a00:2::2 |
| FFMUC | 2001:678:e68:f000:: | 2001:678:ed0:f000:: |
| dnsforge | 2a01:4f8:c013:29d::122 | 2a01:4f8:c010:8c35::175 |
| Digitalcourage | 2a01:4f8:251:554::2 | — |
| Dig.Gesellschaft | 2a05:fc84::42 | 2a05:fc84::43 |
| UncensoredDNS | 2001:67c:28a4:: | 2a01:3a0:53:53:: |
| dismail | 2a01:4f8:1c1b:44aa::1 | 2a01:4f8:c17:739a::2 |

### Not Included

- **Mullvad DNS** (194.242.2.4 / base.dns.mullvad.net) — Only supports DNS-over-HTTPS (DoH) and DNS-over-TLS (DoT), not plain DNS on port 53. Since `dig` uses port 53 by default, Mullvad cannot be tested without adding DoH/DoT support.

## Test Domains

The script tests against a diverse set of domains across regions:

| Domain | Region | Rationale |
|--------|--------|-----------|
| cloudflare.com | US/Global | Major CDN provider |
| akamai.com | US/Global | CDN infrastructure |
| fastly.com | US/Global | CDN infrastructure |
| deutsche-telekom.de | Germany | German telecom |
| hetzner.com | Germany | German hosting provider |
| stackit.cloud | Germany/EU | European cloud platform |
| bbc.co.uk | UK | Major European broadcaster |
| ucl.ac.uk | UK | University College London |
| ntt.co.jp | Japan | Japanese telecom giant |

Each domain is queried 3 times per resolver to calculate an average response time.

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
