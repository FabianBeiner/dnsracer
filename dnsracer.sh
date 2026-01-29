#!/bin/bash

# =========================================================
# dnsracer - Benchmark DNS resolver performance
#            Clean output • Reliable • Cross-platform
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

VERSION="1.0"

# ──────────────────────────────────────────────────────────────
# Debug control – use --debug flag to enable
# ──────────────────────────────────────────────────────────────
DNSBENCH_DEBUG=0

for arg in "$@"; do
  if [ "$arg" = "--debug" ]; then
    DNSBENCH_DEBUG=1
    break
  fi
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

# DNS resolvers - Global selection of major public DNS services
declare -a DNS_NAMES=(
  "Cloudflare"
  "Google"
  "Quad9"
  "OpenDNS"
  "DNS.SB"
  "AdGuard"
  "CleanBrowsing"
  "Comodo"
)

declare -A DNS_PRIMARY=(
  ["Cloudflare"]="1.1.1.1"
  ["Google"]="8.8.8.8"
  ["Quad9"]="9.9.9.9"
  ["OpenDNS"]="208.67.222.222"
  ["DNS.SB"]="185.222.222.222"
  ["AdGuard"]="94.140.14.14"
  ["CleanBrowsing"]="185.228.168.9"
  ["Comodo"]="8.26.56.26"
)

declare -A DNS_SECONDARY=(
  ["Cloudflare"]="1.0.0.1"
  ["Google"]="8.8.4.4"
  ["Quad9"]="149.112.112.112"
  ["OpenDNS"]="208.67.220.220"
  ["DNS.SB"]="45.11.45.11"
  ["AdGuard"]="94.140.15.15"
  ["CleanBrowsing"]="185.228.169.9"
  ["Comodo"]="8.20.247.20"
)

declare -A DNS_DESC=(
  ["Cloudflare"]="Fast global anycast, privacy-focused"
  ["Google"]="Reliable, high uptime, global coverage"
  ["Quad9"]="Security and privacy-focused"
  ["OpenDNS"]="Reliable with optional filtering"
  ["DNS.SB"]="No-logging, privacy-focused"
  ["AdGuard"]="Ad-blocking DNS resolver"
  ["CleanBrowsing"]="Security Filter only filtering"
  ["Comodo"]="Security-focused resolver"
)

TEST_DOMAINS=(
  "google.com"
  "cloudflare.com"
  "github.com"
  "wikipedia.org"
  "heise.de"
  "spiegel.de"
  "deutsche-telekom.de"
)

TESTS_PER_DOMAIN=3
MAX_CONSECUTIVE_FAILURES=2
MIN_SUCCESS_RATE=40

declare -A RESULTS

# ──────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────

print_header() {
  clear
  echo -e "${BOLD}${BLUE}"
  cat <<'EOF'
     ██████╗ ███╗   ██╗███████╗    ██████╗  █████╗  ██████╗███████╗██████╗ 
     ██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗
     ██║  ██║██╔██╗ ██║███████╗    ██████╔╝███████║██║     █████╗  ██████╔╝
     ██║  ██║██║╚██╗██║╚════██║    ██╔══██╗██╔══██║██║     ██╔══╝  ██╔══██╗
     ██████╔╝██║ ╚████║███████║    ██║  ██║██║  ██║╚██████╗███████╗██║  ██║
     ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═╝
EOF
  echo -e "                                                           v${VERSION}${NC}"
  echo ""
  echo "════════════════════════════════════════════════════════════════════════"
  echo " Testing ${#DNS_NAMES[@]} resolvers • ${#TEST_DOMAINS[@]} domains × $TESTS_PER_DOMAIN queries each"
  echo " Early abort after $MAX_CONSECUTIVE_FAILURES consecutive failures"
  if [ "$DNSBENCH_DEBUG" = "1" ]; then
    echo " ${GREEN}Debug mode enabled${NC} → logs to $DEBUG_LOG_FILE"
  fi
  echo "════════════════════════════════════════════════════════════════════════"
  echo ""
  
  local priv=$(get_private_ip)
  local pub=$(get_public_ip)
  echo -e " ${YELLOW}Testing from:${NC} ${BOLD}${priv}${NC} (public: ${pub})"
  echo ""
}

get_private_ip() {
  ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1 || echo "?"
}

get_public_ip() {
  curl -s --connect-timeout 6 https://api.ipify.org 2>/dev/null || echo "?"
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

  echo -e "${BLUE}→${NC} ${BOLD}${name}${NC} ${YELLOW}(${primary}${secondary:+ | ${secondary}})${NC}"

  for domain in "${TEST_DOMAINS[@]}"; do
    for i in $(seq 1 $TESTS_PER_DOMAIN); do
      local server="$primary"
      [ -n "$secondary" ] && [ $success -eq 0 ] && server="$secondary"

      local dig_cmd="dig @$server +tries=1 +time=5 $domain"
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
        printf "  %-20s ${GREEN}%4d ms${NC}\n" "$domain" "$query_time"
      else
        ((consec_fail++))
        local fail_reason
        fail_reason=$(classify_dig_failure "$dig_rc" "$result")
        printf "  %-20s ${RED}%-10s${NC}\n" "$domain" "$fail_reason"

        if [ $consec_fail -ge $MAX_CONSECUTIVE_FAILURES ]; then
          early_abort=1
          echo -e "  ${RED}⚠ Early abort after $MAX_CONSECUTIVE_FAILURES consecutive failures${NC}"
          break 2
        fi
      fi
      sleep 0.2
    done
  done

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
  echo ""
  echo "════════════════════════════════════════════════════════════════════════"
  echo -e "                         ${BOLD}FINAL RANKINGS${NC}"
  echo "════════════════════════════════════════════════════════════════════════"
  echo ""

  printf "${BOLD}%-6s %-20s %-32s %12s    %s${NC}\n" \
         "Rank" "Resolver" "IP Address(es)" "Avg Time" "Success Rate"
  echo "────────────────────────────────────────────────────────────────────────"

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
      printf "${RED}%-6s %-20s %-32s %12s    %3d%%  %b${NC}\n" \
             "$rank." "$name" "${ips:0:32}" "—" "$rate" "$status"
    else
      printf "${color}%-6s %-20s %-32s %9.2f ms    %3d%%${NC}\n" \
             "$rank." "$name" "${ips:0:32}" "$avg" "$rate"
    fi

    ((rank++))
  done

  echo ""
  echo "════════════════════════════════════════════════════════════════════════"
  
  # Calculate recommended mix (best primary from one provider, best secondary from another)
  local best_primary_name="" best_primary_ip="" best_primary_time=9999
  local best_secondary_name="" best_secondary_ip="" best_secondary_time=9999
  
  for key in "${!SERVER_TIMES[@]}"; do
    IFS='|' read -r provider_name ip <<< "$key"
    local time="${SERVER_TIMES[$key]}"
    
    # Check if this is better than current best primary
    if (( $(echo "$time < $best_primary_time" | bc -l) )); then
      best_primary_time="$time"
      best_primary_ip="$ip"
      best_primary_name="$provider_name"
    fi
  done
  
  # Find best secondary from a DIFFERENT provider
  for key in "${!SERVER_TIMES[@]}"; do
    IFS='|' read -r provider_name ip <<< "$key"
    local time="${SERVER_TIMES[$key]}"
    
    # Skip if same provider as primary
    [ "$provider_name" = "$best_primary_name" ] && continue
    
    if (( $(echo "$time < $best_secondary_time" | bc -l) )); then
      best_secondary_time="$time"
      best_secondary_ip="$ip"
      best_secondary_name="$provider_name"
    fi
  done
  
  if [ "$best_primary_ip" != "" ] && [ "$best_secondary_ip" != "" ]; then
    echo ""
    echo -e "${BOLD}${GREEN}Recommended Configuration (Best Mix):${NC}"
    echo "────────────────────────────────────────────────────────────────────────"
    echo -e " Primary:   ${BOLD}$best_primary_ip${NC} ($best_primary_name - $(printf "%.2f" $best_primary_time) ms)"
    echo -e " Secondary: ${BOLD}$best_secondary_ip${NC} ($best_secondary_name - $(printf "%.2f" $best_secondary_time) ms)"
    echo ""
    echo -e " ${YELLOW}This provides redundancy across different providers${NC}"
  fi
  
  echo ""
  echo "════════════════════════════════════════════════════════════════════════"
  echo ""
  echo -e "${BLUE}Tips:${NC}"
  echo " • Lower latency is better - top performers typically show <20ms"
  echo " • Geographic distance to DNS servers affects response time"
  echo " • Using servers from different providers increases redundancy"
  echo " • Early abort usually means port 53 UDP is blocked or unreachable"
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
  if [ "$DNSBENCH_DEBUG" = "1" ]; then
    > "$DEBUG_LOG_FILE" 2>/dev/null || true
    debug "Script started with --debug flag"
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
