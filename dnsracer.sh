#!/bin/bash

# =========================================================
# dnsracer - Benchmark DNS resolver performance
#            Clean output • Reliable • Cross-platform
#            IPv4 + IPv6 support with auto-detection
# =========================================================
#
# MIT License
# 
# Copyright (c) 2026 Fabian Beiner
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

VERSION="1.2"

# ──────────────────────────────────────────────────────────────
# Flags – use --help, --verbose, --debug
# ──────────────────────────────────────────────────────────────
DNSBENCH_DEBUG=0
VERBOSE=0

for arg in "$@"; do
  case "$arg" in
    --help|-h)
      # Defer to show_help() after function definitions
      SHOW_HELP=1
      ;;
    --verbose|-v)
      VERBOSE=1
      ;;
    --debug)
      DNSBENCH_DEBUG=1
      ;;
  esac
done

DEBUG_LOG_FILE="dnsracer-debug.log"

debug() {
  [ "$DNSBENCH_DEBUG" = "1" ] && echo "[DEBUG $(date '+%H:%M:%S')] $*" >> "$DEBUG_LOG_FILE"
}

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Check IPv6 availability
HAS_IPV6=0
if ip -6 addr show scope global 2>/dev/null | grep -q 'inet6'; then
  HAS_IPV6=1
fi

# DNS resolvers - Global selection of major public DNS services
declare -a DNS_NAMES_V4=(
  "Cloudflare"
  "Google"
  "Quad9"
  "OpenDNS"
  "DNS.SB"
  "AdGuard"
  "CleanBrowsing"
  "Comodo"
  "FFMUC"
  "dnsforge"
  "Digitalcourage"
  "DigitaleGesellschaft"
  "UncensoredDNS"
  "dismail"
)

declare -a DNS_NAMES_V6=(
  "Cloudflare-v6"
  "Google-v6"
  "Quad9-v6"
  "OpenDNS-v6"
  "DNS.SB-v6"
  "AdGuard-v6"
  "CleanBrowsing-v6"
  "FFMUC-v6"
  "dnsforge-v6"
  "Digitalcourage-v6"
  "DigitaleGesellschaft-v6"
  "UncensoredDNS-v6"
  "dismail-v6"
)

# Build the full DNS_NAMES array based on IPv6 availability
declare -a DNS_NAMES=("${DNS_NAMES_V4[@]}")
if [ "$HAS_IPV6" = "1" ]; then
  DNS_NAMES+=("${DNS_NAMES_V6[@]}")
fi

declare -A DNS_PRIMARY=(
  ["Cloudflare"]="1.1.1.1"
  ["Cloudflare-v6"]="2606:4700:4700::1111"

  ["Google"]="8.8.8.8"
  ["Google-v6"]="2001:4860:4860::8888"

  ["Quad9"]="9.9.9.9"
  ["Quad9-v6"]="2620:fe::fe"

  ["OpenDNS"]="208.67.222.222"
  ["OpenDNS-v6"]="2620:119:35::35"

  ["DNS.SB"]="185.222.222.222"
  ["DNS.SB-v6"]="2a09::"

  ["AdGuard"]="94.140.14.14"
  ["AdGuard-v6"]="2a10:50c0::ad1:ff"

  ["CleanBrowsing"]="185.228.168.9"
  ["CleanBrowsing-v6"]="2a0d:2a00:1::2"

  ["Comodo"]="8.26.56.26"

  ["FFMUC"]="185.150.99.255"
  ["FFMUC-v6"]="2001:678:e68:f000::"

  ["dnsforge"]="49.12.67.122"
  ["dnsforge-v6"]="2a01:4f8:c013:29d::122"

  ["Digitalcourage"]="5.9.164.112"
  ["Digitalcourage-v6"]="2a01:4f8:251:554::2"

  ["DigitaleGesellschaft"]="185.95.218.42"
  ["DigitaleGesellschaft-v6"]="2a05:fc84::42"

  ["UncensoredDNS"]="91.239.100.100"
  ["UncensoredDNS-v6"]="2001:67c:28a4::"

  ["dismail"]="116.203.32.217"
  ["dismail-v6"]="2a01:4f8:1c1b:44aa::1"
)

declare -A DNS_SECONDARY=(
  ["Cloudflare"]="1.0.0.1"
  ["Cloudflare-v6"]="2606:4700:4700::1001"

  ["Google"]="8.8.4.4"
  ["Google-v6"]="2001:4860:4860::8844"

  ["Quad9"]="149.112.112.112"
  ["Quad9-v6"]="2620:fe::9"

  ["OpenDNS"]="208.67.220.220"
  ["OpenDNS-v6"]="2620:119:53::53"

  ["DNS.SB"]="45.11.45.11"
  ["DNS.SB-v6"]="2a11::"

  ["AdGuard"]="94.140.15.15"
  ["AdGuard-v6"]="2a10:50c0::ad2:ff"

  ["CleanBrowsing"]="185.228.169.9"
  ["CleanBrowsing-v6"]="2a0d:2a00:2::2"

  ["Comodo"]="8.20.247.20"

  ["FFMUC"]="5.1.66.255"
  ["FFMUC-v6"]="2001:678:ed0:f000::"

  ["dnsforge"]="91.99.154.175"
  ["dnsforge-v6"]="2a01:4f8:c010:8c35::175"

  ["DigitaleGesellschaft"]="185.95.218.43"
  ["DigitaleGesellschaft-v6"]="2a05:fc84::43"

  ["UncensoredDNS"]="89.233.43.71"
  ["UncensoredDNS-v6"]="2a01:3a0:53:53::"

  ["dismail"]="159.69.114.157"
  ["dismail-v6"]="2a01:4f8:c17:739a::2"
)

declare -A DNS_DESC=(
  ["Cloudflare"]="Public anycast resolver (fast). Supports encrypted DNS (DoT/DoH)."
  ["Cloudflare-v6"]="Cloudflare IPv6 resolver. Supports encrypted DNS (DoT/DoH)."

  ["Google"]="Public anycast resolver with global coverage; focus on reliability/performance."
  ["Google-v6"]="Google Public DNS IPv6 resolver with global coverage."

  ["Quad9"]="Security-focused public resolver blocking malicious domains; DNSSEC + encrypted DNS."
  ["Quad9-v6"]="Quad9 IPv6 security-focused resolver blocking malicious domains; DNSSEC + encrypted DNS."

  ["OpenDNS"]="Cisco OpenDNS (Umbrella) public resolver. Optional filtering via Umbrella."
  ["OpenDNS-v6"]="Cisco OpenDNS IPv6 public resolver. Optional filtering via Umbrella."

  ["DNS.SB"]="Privacy-focused resolver (no logs per provider). DNSSEC + encrypted DNS."
  ["DNS.SB-v6"]="DNS.SB IPv6 privacy-focused resolver. DNSSEC + encrypted DNS."

  ["AdGuard"]="AdGuard DNS blocks ads, trackers and phishing domains. Encrypted DNS supported."
  ["AdGuard-v6"]="AdGuard DNS IPv6 blocks ads, trackers and phishing domains."

  ["CleanBrowsing"]="Security Filter blocks malware, phishing and abusive domains. DoT/DoH."
  ["CleanBrowsing-v6"]="CleanBrowsing Security Filter IPv6. Blocks malware, phishing and abusive domains."

  ["Comodo"]="Comodo Secure DNS security-oriented resolver (IPv4 only)."

  ["FFMUC"]="Freifunk München community DNS resolver. Supports DoT/DoH/DoQ."
  ["FFMUC-v6"]="Freifunk München IPv6 community DNS resolver. Supports DoT/DoH/DoQ."

  ["dnsforge"]="dnsforge.de resolver with ad, tracker and malware blocking."
  ["dnsforge-v6"]="dnsforge.de IPv6 resolver with ad, tracker and malware blocking."

  ["Digitalcourage"]="Digitalcourage DNS (Germany). DoT-only resolver for censorship circumvention."
  ["Digitalcourage-v6"]="Digitalcourage IPv6 DoT-only resolver for censorship circumvention."

  ["DigitaleGesellschaft"]="Digitale Gesellschaft Switzerland privacy-oriented resolver. No blocklists, DNSSEC."
  ["DigitaleGesellschaft-v6"]="Digitale Gesellschaft Switzerland IPv6 privacy-oriented resolver. No blocklists, DNSSEC."

  ["UncensoredDNS"]="Danish uncensored resolver. Supports encrypted DNS (DoT/DoH)."
  ["UncensoredDNS-v6"]="UncensoredDNS IPv6 resolver. Supports encrypted DNS (DoT/DoH)."

  ["dismail"]="dismail.de privacy-focused DNS with blocklists. DoT supported."
  ["dismail-v6"]="dismail.de IPv6 privacy-focused DNS with blocklists. DoT supported."
)

TEST_DOMAINS=(
  "cloudflare.com"
  "akamai.com"
  "fastly.com"
  "deutsche-telekom.de"
  "hetzner.com"
  "stackit.cloud"
  "bbc.co.uk"
  "ucl.ac.uk"
  "ntt.co.jp"
)

TESTS_PER_DOMAIN=3
MAX_CONSECUTIVE_FAILURES=2
MIN_SUCCESS_RATE=40

declare -A RESULTS

# ──────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────

show_help() {
  echo "dnsracer v${VERSION} - Benchmark DNS resolver performance"
  echo ""
  echo "Usage: ./dnsracer.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --help, -h       Show this help screen and exit"
  echo "  --verbose, -v    Show per-query results (detailed output)"
  echo "  --debug          Enable debug logging to $DEBUG_LOG_FILE"
  echo ""

  local dash="-"   # ASCII only (prevents width/rendering issues)
  local name primary secondary desc
  local name_w=0 primary_w=0 secondary_w=0

  # Compute widths across BOTH v4 and v6 so tables align visually
  for name in "${DNS_NAMES_V4[@]}" "${DNS_NAMES_V6[@]}"; do
    primary="${DNS_PRIMARY[$name]}"
    secondary="${DNS_SECONDARY[$name]}"
    [ -z "$secondary" ] && secondary="$dash"

    (( ${#name} > name_w )) && name_w=${#name}
    (( ${#primary} > primary_w )) && primary_w=${#primary}
    (( ${#secondary} > secondary_w )) && secondary_w=${#secondary}
  done

  # Minimum widths for readability
  (( name_w < 20 )) && name_w=20
  (( primary_w < 18 )) && primary_w=18
  (( secondary_w < 18 )) && secondary_w=18

  echo "Tested IPv4 Resolvers:"
  for name in "${DNS_NAMES_V4[@]}"; do
    primary="${DNS_PRIMARY[$name]}"
    secondary="${DNS_SECONDARY[$name]}"
    desc="${DNS_DESC[$name]}"
    [ -z "$secondary" ] && secondary="$dash"
    printf "  %-${name_w}s %-${primary_w}s %-${secondary_w}s %s\n" "$name" "$primary" "$secondary" "$desc"
  done

  echo ""
  echo "Tested IPv6 Resolvers:"
  for name in "${DNS_NAMES_V6[@]}"; do
    primary="${DNS_PRIMARY[$name]}"
    secondary="${DNS_SECONDARY[$name]}"
    [ -z "$secondary" ] && secondary="$dash"
    printf "  %-${name_w}s %-${primary_w}s %-${secondary_w}s\n" "$name" "$primary" "$secondary"
  done

  echo ""
  echo "Test Domains:"
  for domain in "${TEST_DOMAINS[@]}"; do
    echo "  $domain"
  done
  echo ""
  echo "Each domain is queried ${TESTS_PER_DOMAIN} times per resolver."
}

show_current_dns() {
  local dns_servers=""

  if [ -f /etc/resolv.conf ]; then
    dns_servers=$(grep -E '^\s*nameserver\s+' /etc/resolv.conf 2>/dev/null \
      | awk '{print $2}' | paste -sd ', ' -)
  fi

  if [ -z "$dns_servers" ] && command -v resolvectl &>/dev/null; then
    dns_servers=$(resolvectl status 2>/dev/null \
      | grep -oP 'DNS Servers:\s*\K.*' | paste -sd ', ' -)
  fi

  if [ -z "$dns_servers" ] && command -v scutil &>/dev/null; then
    dns_servers=$(scutil --dns 2>/dev/null \
      | grep -oP 'nameserver\[0-9*\]\s*:\s*\K\S+' | sort -u | paste -sd ', ' -)
  fi

  if [ -n "$dns_servers" ]; then
    echo -e " ${YELLOW}DNS: ${NC} ${dns_servers}"
  fi
}

print_header() {
  printf '\033[2J\033[H'
  echo -e "${BOLD}${BLUE}"
  cat <<'EOF'
██████╗ ███╗   ██╗███████╗    ██████╗  █████╗  ██████╗███████╗██████╗ 
██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗
██║  ██║██╔██╗ ██║███████╗    ██████╔╝███████║██║     █████╗  ██████╔╝
██║  ██║██║╚██╗██║╚════██║    ██╔══██╗██╔══██║██║     ██╔══╝  ██╔══██╗
██████╔╝██║ ╚████║███████║    ██║  ██║██║  ██║╚██████╗███████╗██║  ██║
╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝
EOF
  echo -e "                                                                  v${VERSION}${NC}"
  echo ""
  echo "══════════════════════════════════════════════════════════════════════"
  echo " Testing ${#DNS_NAMES[@]} resolvers • ${#TEST_DOMAINS[@]} domains × $TESTS_PER_DOMAIN queries each"
  if [ "$HAS_IPV6" = "1" ]; then
    echo -e " ${GREEN}IPv6 detected${NC} - testing both IPv4 and IPv6 resolvers"
  else
    echo -e " ${YELLOW}IPv6 not available${NC} - testing IPv4 resolvers only"
  fi
  echo " Early abort after $MAX_CONSECUTIVE_FAILURES consecutive failures"
  if [ "$DNSBENCH_DEBUG" = "1" ]; then
    echo -e " ${GREEN}Debug mode enabled${NC} → logs to $DEBUG_LOG_FILE"
  fi
  echo "══════════════════════════════════════════════════════════════════════"
  echo ""
  
  local priv_v4=$(get_private_ip)
  local pub_v4=$(get_public_ip)
  echo -e " ${YELLOW}IPv4:${NC} ${BOLD}${priv_v4}${NC} (public: ${pub_v4})"
  
  if [ "$HAS_IPV6" = "1" ]; then
    local priv_v6=$(get_private_ipv6)
    local pub_v6=$(get_public_ipv6)
    echo -e " ${YELLOW}IPv6:${NC} ${BOLD}${priv_v6}${NC} (public: ${pub_v6})"
  fi
  show_current_dns
  echo ""
}

get_private_ip() {
  ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1 || echo "?"
}

get_public_ip() {
  curl -4 -s --connect-timeout 6 https://api.ipify.org 2>/dev/null || echo "?"
}

get_private_ipv6() {
  ip -6 addr show scope global 2>/dev/null | grep -oP '(?<=inet6\s)[\da-f:]+' | head -n1 || echo "?"
}

get_public_ipv6() {
  curl -6 -s --connect-timeout 6 https://api64.ipify.org 2>/dev/null || echo "?"
}

classify_dig_failure() {
  local rc="$1"
  local output="$2"

  if [ "$rc" -eq 9 ] || echo "$output" | grep -qi "timed out\|no servers could be reached"; then
    echo "Timeout"
  elif echo "$output" | grep -qi "connection refused"; then
    echo "Refused"
  elif echo "$output" | grep -qi "REFUSED"; then
    echo "REFUSED"
  elif echo "$output" | grep -qi "SERVFAIL\|FORMERR"; then
    echo "ServerErr"
  elif [ "$rc" -eq 0 ] && ! echo "$output" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
    echo "NoAnswer"
  else
    echo "Failed($rc)"
  fi
}

test_dns_server() {
  local name="$1"
  local primary="${DNS_PRIMARY[$name]}"
  local secondary="${DNS_SECONDARY[$name]}"
  local total_ms=0 success=0 total=$(( ${#TEST_DOMAINS[@]} * TESTS_PER_DOMAIN ))
  local consec_fail=0 early_abort=0
  local query_num=0

  # Spinner characters (braille pattern)
  local spinner_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

  # Determine if this is IPv6 based on address format
  local is_ipv6=0
  [[ "$primary" =~ : ]] && is_ipv6=1

  echo -e "${BLUE}→${NC} ${BOLD}${name}${NC} ${YELLOW}(${primary}${secondary:+ | ${secondary}})${NC}"

  for domain in "${TEST_DOMAINS[@]}"; do
    for i in $(seq 1 $TESTS_PER_DOMAIN); do
      ((query_num++))

      # Show spinner in non-verbose mode
      if [ "$VERBOSE" != "1" ]; then
        local si=$(( (query_num - 1) % ${#spinner_chars} ))
        local spin_char="${spinner_chars:$si:1}"
        printf "\r  ${BLUE}${spin_char}${NC} Testing... (%d/%d)" "$query_num" "$total"
      fi

      local server="$primary"
      [ -n "$secondary" ] && [ $success -eq 0 ] && server="$secondary"

      # Use appropriate dig flags for IPv6
      local dig_flags="+tries=1 +time=5"
      if [ $is_ipv6 -eq 1 ]; then
        dig_flags="-6 $dig_flags"
      fi

      local dig_cmd="dig $dig_flags @$server $domain"
      debug "Executing: $dig_cmd"

      result=$(eval "$dig_cmd" 2>&1)
      local dig_rc=$?

      debug "Exit code: $dig_rc"
      debug "Output: ${result:0:200}"

      if [ $dig_rc -eq 0 ] && echo "$result" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
        query_time=$(echo "$result" | grep -oP ';; Query time: \K\d+' || echo "0")
        if [ "$query_time" = "0" ]; then
          query_time=$(echo "$result" | grep -oP 'Query time: \K\d+' || echo "1")
        fi
        ((total_ms += query_time))
        ((success++))
        consec_fail=0
        [ "$VERBOSE" = "1" ] && printf "  %-20s ${GREEN}%4d ms${NC}\n" "$domain" "$query_time"
      else
        ((consec_fail++))
        local fail_reason
        fail_reason=$(classify_dig_failure "$dig_rc" "$result")
        [ "$VERBOSE" = "1" ] && printf "  %-20s ${RED}%-10s${NC}\n" "$domain" "$fail_reason"

        if [ $consec_fail -ge $MAX_CONSECUTIVE_FAILURES ]; then
          early_abort=1
          # Clear spinner line before printing abort message
          [ "$VERBOSE" != "1" ] && printf "\r\033[K"
          echo -e "  ${RED}⚠ Early abort after $MAX_CONSECUTIVE_FAILURES consecutive failures${NC}"
          break 2
        fi
      fi
      sleep 0.2
    done
  done

  # Clear spinner line
  [ "$VERBOSE" != "1" ] && printf "\r\033[K"

  if [ $early_abort -eq 1 ]; then
    RESULTS["$name"]="9999|$success|$((total-success))|$total|early"
    echo ""
    return
  fi

  if [ $success -gt 0 ]; then
    local avg=$(bc -l <<< "scale=2; $total_ms / $success" 2>/dev/null || echo "9999")
    local rate=$(( success * 100 / total ))
    RESULTS["$name"]="$avg|$success|$((total-success))|$total|ok"

    local mark=""
    [ $rate -ge 95 ] && mark="${GREEN}✓ Excellent${NC}"
    [ $rate -ge 80 ] && [ -z "$mark" ] && mark="${YELLOW}✓ Good${NC}"
    [ $rate -lt $MIN_SUCCESS_RATE ] && mark="${RED}⚠ Low reliability${NC}"

    echo -e "  ${BOLD}Average: ${avg} ms${NC}  •  ${success}/${total} successful (${rate}%)${mark:+  •  $mark}"
  else
    echo -e "  ${RED}All queries failed${NC}"
    RESULTS["$name"]="9999|0|${total}|${total}|failed"
  fi
  echo ""
}

display_results() {
  # Table width = 6+1+20+1+38+1+12+4+12 = 95 (matches header format)
  local tw=95
  local sep_double=$(printf '═%.0s' $(seq 1 $tw))
  local sep_single=$(printf '─%.0s' $(seq 1 $tw))

  echo ""
  echo "$sep_double"
  printf "%*s\n" $(( (tw + 14) / 2 )) "FINAL RANKINGS"
  echo "$sep_double"
  echo ""

  printf "${BOLD}%-6s %-20s %-38s %12s    %s${NC}\n" \
         "Rank" "Resolver" "IP Address(es)" "Avg Time" "Success Rate"
  echo "$sep_single"

  # Track individual server performance for recommendations
  declare -A SERVER_TIMES
  
  local rank=1
  for entry in $(for k in "${!RESULTS[@]}"; do echo "${RESULTS[$k]}|$k"; done | sort -t'|' -k1,1n); do
    IFS='|' read -r avg succ fail tot early name <<< "$entry"

    local primary="${DNS_PRIMARY[$name]}"
    local secondary="${DNS_SECONDARY[$name]}"
    local ips="$primary"
    [ -n "$secondary" ] && ips="${primary}, ${secondary}"

    # Store individual server times (approximation based on avg)
    if [ "$avg" != "9999" ]; then
      SERVER_TIMES["$name|$primary"]="$avg"
      [ -n "$secondary" ] && SERVER_TIMES["$name|$secondary"]="$avg"
    fi

    local status="OK"
    [ "$early" = "early" ] && status="${RED}Early abort${NC}"
    [ "$early" = "failed" ] && status="${RED}Failed${NC}"
    [ "$avg" = "9999" ] && status="${RED}Failed${NC}"

    local rate=0
    [ $tot -gt 0 ] && rate=$(( succ * 100 / tot ))

    local color="$NC"
    if [ "$avg" != "9999" ]; then
      ((rank==1)) && color="${GREEN}${BOLD}"
      ((rank==2)) && color="${GREEN}"
      ((rank==3)) && color="${YELLOW}"
    fi

    if [ "$avg" = "9999" ]; then
      printf "${RED}%-6s %-20s %-38s %12s    %3d%%  %b${NC}\n" \
             "$rank." "$name" "${ips:0:38}" "—" "$rate" "$status"
    else
      printf "${color}%-6s %-20s %-38s %9.2f ms    %3d%%${NC}\n" \
             "$rank." "$name" "${ips:0:38}" "$avg" "$rate"
    fi

    ((rank++))
  done

  echo ""
  echo "$sep_double"

  # Calculate recommended mix - separate for IPv4 and IPv6
  local best_v4_primary_name="" best_v4_primary_ip="" best_v4_primary_time=9999
  local best_v4_secondary_name="" best_v4_secondary_ip="" best_v4_secondary_time=9999
  local best_v6_primary_name="" best_v6_primary_ip="" best_v6_primary_time=9999
  local best_v6_secondary_name="" best_v6_secondary_ip="" best_v6_secondary_time=9999
  
  # Separate IPv4 and IPv6 servers
  for key in "${!SERVER_TIMES[@]}"; do
    IFS='|' read -r provider_name ip <<< "$key"
    local time="${SERVER_TIMES[$key]}"
    
    # Check if IPv6 or IPv4
    if [[ "$ip" =~ : ]]; then
      # IPv6
      if (( $(echo "$time < $best_v6_primary_time" | bc -l) )); then
        best_v6_primary_time="$time"
        best_v6_primary_ip="$ip"
        best_v6_primary_name="$provider_name"
      fi
    else
      # IPv4
      if (( $(echo "$time < $best_v4_primary_time" | bc -l) )); then
        best_v4_primary_time="$time"
        best_v4_primary_ip="$ip"
        best_v4_primary_name="$provider_name"
      fi
    fi
  done
  
  # Find best secondary for IPv4 from DIFFERENT provider
  for key in "${!SERVER_TIMES[@]}"; do
    IFS='|' read -r provider_name ip <<< "$key"
    local time="${SERVER_TIMES[$key]}"
    
    # Skip IPv6
    [[ "$ip" =~ : ]] && continue
    
    # Strip -v6 suffix for provider comparison
    local provider_base="${provider_name%-v6}"
    local best_provider_base="${best_v4_primary_name%-v6}"
    
    # Skip if same base provider as primary
    [ "$provider_base" = "$best_provider_base" ] && continue
    
    if (( $(echo "$time < $best_v4_secondary_time" | bc -l) )); then
      best_v4_secondary_time="$time"
      best_v4_secondary_ip="$ip"
      best_v4_secondary_name="$provider_name"
    fi
  done
  
  # Find best secondary for IPv6 from DIFFERENT provider
  if [ "$HAS_IPV6" = "1" ]; then
    for key in "${!SERVER_TIMES[@]}"; do
      IFS='|' read -r provider_name ip <<< "$key"
      local time="${SERVER_TIMES[$key]}"
      
      # Skip IPv4
      [[ ! "$ip" =~ : ]] && continue
      
      # Strip -v6 suffix for provider comparison
      local provider_base="${provider_name%-v6}"
      local best_provider_base="${best_v6_primary_name%-v6}"
      
      # Skip if same base provider as primary
      [ "$provider_base" = "$best_provider_base" ] && continue
      
      if (( $(echo "$time < $best_v6_secondary_time" | bc -l) )); then
        best_v6_secondary_time="$time"
        best_v6_secondary_ip="$ip"
        best_v6_secondary_name="$provider_name"
      fi
    done
  fi
  
  # Display IPv4 recommendation
  if [ "$best_v4_primary_ip" != "" ] && [ "$best_v4_secondary_ip" != "" ]; then
    echo ""
    echo -e "${BOLD}${GREEN}Recommended IPv4 Configuration (Best Mix):${NC}"
    echo "$sep_single"
    echo -e " Primary:   ${BOLD}$best_v4_primary_ip${NC}"
    echo -e "            ($best_v4_primary_name - $(printf "%.2f" $best_v4_primary_time) ms)"
    echo -e " Secondary: ${BOLD}$best_v4_secondary_ip${NC}"
    echo -e "            ($best_v4_secondary_name - $(printf "%.2f" $best_v4_secondary_time) ms)"
  fi
  
  # Display IPv6 recommendation
  if [ "$HAS_IPV6" = "1" ] && [ "$best_v6_primary_ip" != "" ] && [ "$best_v6_secondary_ip" != "" ]; then
    echo ""
    echo -e "${BOLD}${GREEN}Recommended IPv6 Configuration (Best Mix):${NC}"
    echo "$sep_single"
    echo -e " Primary:   ${BOLD}$best_v6_primary_ip${NC}"
    echo -e "            ($best_v6_primary_name - $(printf "%.2f" $best_v6_primary_time) ms)"
    echo -e " Secondary: ${BOLD}$best_v6_secondary_ip${NC}"
    echo -e "            ($best_v6_secondary_name - $(printf "%.2f" $best_v6_secondary_time) ms)"
  fi
  
  if [ "$best_v4_primary_ip" != "" ] || [ "$best_v6_primary_ip" != "" ]; then
    echo ""
    echo -e " ${YELLOW}These configurations provide redundancy across different providers${NC}"
  fi
  
  echo ""
  echo "$sep_double"
  echo ""
  echo -e "${BLUE}Tips:${NC}"
  echo " • Lower latency is better - top performers typically show <20ms"
  echo " • Geographic distance to DNS servers affects response time"
  echo " • Using servers from different providers increases redundancy"
  if [ "$HAS_IPV6" = "1" ]; then
    echo " • IPv6 can sometimes be faster than IPv4 (or vice versa)"
  fi
  echo " • Early abort usually means port 53 UDP is blocked or unreachable"
  echo -e " • Run with ${BOLD}./dnsracer.sh --verbose${NC} to see per-query results"
  echo -e " • Run with ${BOLD}./dnsracer.sh --debug${NC} for detailed logging"
  echo ""
}

check_requirements() {
  for cmd in dig bc curl; do
    command -v "$cmd" &>/dev/null || {
      echo -e "${RED}Error: Missing required tool: $cmd${NC}"
      echo "Install with: sudo apt install dnsutils bc curl"
      exit 1
    }
  done
}

main() {
  if [ "$SHOW_HELP" = "1" ]; then
    show_help
    exit 0
  fi

  if [ "$DNSBENCH_DEBUG" = "1" ]; then
    > "$DEBUG_LOG_FILE" 2>/dev/null || true
    debug "Script started with --debug flag"
    debug "IPv6 available: $HAS_IPV6"
  fi

  check_requirements
  print_header

  for name in "${DNS_NAMES[@]}"; do
    test_dns_server "$name"
  done

  display_results
  
  if [ "$DNSBENCH_DEBUG" = "1" ]; then
    debug "Script finished"
    echo "Debug log saved to: $DEBUG_LOG_FILE"
  fi
}

main

exit 0
