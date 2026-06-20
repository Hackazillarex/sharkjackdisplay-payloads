# Network Hunter v1.0
by Hackazillarex

**Red Team Network Enumeration & Credential Spraying Payload for Shark Jack Display**


A modular reconnaissance payload designed for automated network discovery, service enumeration, and credential testing across multiple protocols (FTP, SSH, SMB, HTTP). Includes Cloud C2 integration for seamless data exfiltration.

---

## Features

### 🔍 Network Enumeration
- **Network Scan** — Discovers live hosts via ping sweep and performs port/service enumeration on 16 common attack vectors
- Scans: FTP, SSH, DNS, Kerberos, RPC, LDAP, HTTPS, SMB, AD services, RDP, WinRM, HTTP proxy, Print spooler

### 🎯 Service-Specific Modules

**FTP Credential Spray**
- Tests 21 default FTP credentials (anonymous, guest, admin, root, ftp, user, ftpuser variants)
- Exit code detection for reliable login validation
- Post-recon guidance for file enumeration and credential hunting

**SSH Reconnaissance**
- Detects SSH services on the network
- Provides guidance for hydra spraying, key enumeration, and version fingerprinting
- Recommends password reuse analysis across systems

**SMB Enumeration**
- Identifies SMB shares and domain services
- Suggests null session testing, share enumeration, and AD attacks
- Recommends enum4linux, crackmapexec, and Responder for follow-up

**HTTP Path Discovery**
- Enumerates 14 common web paths (/admin, /login, /phpmyadmin, /.git, /.env, etc.)
- Reports HTTP response codes for discovered endpoints
- Suggests dirbuster/ffuf, whatweb, and form brute-forcing next steps

### 📤 C2 Integration
- Automatic exfiltration to Cloud C2 infrastructure
- Fallback to local storage if C2 unavailable
- Graceful error handling with silent failures

### 📋 Organized Loot Management
- Timestamped results per service type
- Centralized loot directory: `/root/loot/network_hunter/`
- Integrated error logging
- Browsable loot file viewer in the payload menu

---

## Usage

### Quick Start
1. Plug in Shark Jack Display and connect to target network
2. Select **Network Scan (Run First)** from menu
3. Wait for scan to complete (displays live hosts and open ports)
4. Choose service-specific spray:
   - **FTP Spray** — Test FTP credentials
   - **SSH Recon** — Detect SSH services
   - **SMB Enum** — Identify SMB shares
   - **HTTP Enum** — Find default web paths
5. Or select **Run All** to execute everything sequentially

### Menu System
```
Network Hunter v1.0
├─ Network Scan (Run First)    [Required for all other options]
├─ FTP Spray                    [21 credential combinations]
├─ SSH Recon                    [Service detection + guidance]
├─ SMB Enum                     [Share detection + guidance]
├─ HTTP Enum                    [Path discovery]
├─ Run All                      [Execute all in sequence]
├─ View Loot Files              [Browse previous results]
└─ Quit
```

---

## Loot Structure

All results are stored in `/root/loot/network_hunter/`:

```
network_hunter/
├── network_hunter_2026-06-19_14-30-45.txt    [Network scan results]
├── ftp_spray_2026-06-19_14-35-12.txt         [FTP findings]
├── ssh_recon_2026-06-19_14-36-02.txt         [SSH findings]
├── smb_enum_2026-06-19_14-37-15.txt          [SMB findings]
├── http_enum_2026-06-19_14-38-30.txt         [HTTP findings]
├── all_spray_2026-06-19_14-40-00.txt         [Run All output]
└── errors.log                                 [Error tracking]
```

---

## FTP Credentials Tested

The payload includes 21 default FTP credential combinations:

| Username | Passwords |
|----------|-----------|
| anonymous | (blank), anonymous, email@example.com |
| guest | (blank), guest, password |
| admin | admin, password, 12345, 123456 |
| ftp | ftp |
| test | test, password |
| root | root, toor, password |
| user | user, password, 12345 |
| ftpuser | ftpuser, password |

**Pro tip:** Credentials are tested against all FTP targets in parallel for speed.

---

## Post-Recon Guidance

Each service module includes actionable next steps logged in loot files:

### FTP Success
```
Post-Recon Next Steps:
  1. Connect: ftp <ip>
  2. List files: ls -la
  3. Download sensitive files: get filename
  4. Check for credentials in config files
  5. Enumerate user directories and permissions
```

### SSH Detection
```
Post-Recon Next Steps:
  1. Attempt password spray: hydra -L users.txt -P pass.txt ssh://<ip>
  2. SSH key enumeration: ssh-keyscan -t rsa <ip>
  3. Check for default/weak credentials: admin/admin, root/root, etc
  4. Banner grabbing: ssh -v <ip> 2>&1 | grep -i version
  5. Once connected: check for password reuse across systems
```

### SMB Detection
```
Post-Recon Next Steps:
  1. Attempt null session: smbclient -L //<ip> -U '' -N
  2. Enumerate shares: smbclient -L //<ip> -U $user%$pass
  3. Test guest access: smbclient //<ip>/IPC$ -U guest%
  4. Domain enumeration (common tools):
     - enum4linux: enum4linux -a <ip>
     - crackmapexec: crackmapexec smb <ip> -u $user -p $pass
  5. Kerberoasting (requires Impacket):
     - GetUserSPNs.py -dc-ip <ip> domain.com/ -u $user -p $pass
  6. Run Responder for LLMNR/NBT-NS poisoning
```

### HTTP Detection
```
Post-Recon Next Steps:
  1. Enumerate with dirbuster/ffuf: ffuf -w wordlist.txt -u http://<ip>/FUZZ
  2. Check robots.txt: curl http://<ip>/robots.txt
  3. Identify CMS: whatweb http://<ip>
  4. Screenshot: cutycapt --url=http://<ip> --out=/tmp/<ip>.png
  5. Brute force forms: hydra -l admin -P pass.txt http://<ip>/ -V
```

---

## Technical Details

### Port Enumeration
The payload scans 16 ports targeting common red team vectors:
```
21 (FTP), 22 (SSH), 53 (DNS), 88 (Kerberos)
135 (RPC), 139 (NetBIOS), 389 (LDAP), 443 (HTTPS)
445 (SMB), 3268/3269 (Global Catalog), 3389 (RDP)
5985/5986 (WinRM), 8080 (HTTP proxy), 9100 (Print spooler)
```

### FTP Detection Logic
- Uses `curl` with exit code analysis for reliable login detection
- Exit code **19** = Login successful (file operation failed post-auth)
- Exit code **67** = Login denied
- Pre-checks TCP connectivity to avoid false positives

### SSH/SMB/HTTP Modules
- **Detection-only** design (no client tools required on Shark Jack)
- Identifies open ports and provides enumeration guidance
- Reduces payload complexity while maintaining usability

### C2 Exfiltration
- Checks for `/etc/device.config` (Cloud C2 configuration)
- Extracts C2 host IP automatically
- Tests connectivity before attempting upload
- Falls back to local storage if C2 unavailable
- Uses `C2CONNECT`, `CLOUDLOG`, and `C2EXFIL` Shark Jack API

---

## Troubleshooting

### "Run Scan Network first!" error
All spray modules require the network scan to run first. The payload checks for scan results in `/tmp/nh_scan_results.txt`.

### FTP spray showing no results despite open port
- Ensure nmap scan completed successfully
- Check if FTP service is actually responding: `curl -v ftp://<ip>`
- Verify credentials in the credential list or add custom ones

### C2 exfiltration not working
- Verify `/etc/device.config` contains valid C2 IP
- Test connectivity: `ping <C2_IP>`
- Check Cloud C2 port (default 8080) is accessible
- Loot is still saved locally in `/root/loot/network_hunter/`


---

## Customization

### Add Custom FTP Credentials
Edit the `FTP_CREDS` array in `setup_payload()`:
```bash
declare -gA FTP_CREDS=(
  [0]="user1:pass1"
  [1]="user2:pass2"
  # ... add more
)
```

### Add Custom HTTP Paths
Edit the `DEFAULT_PATHS` array in `spray_http_all()`:
```bash
declare -a DEFAULT_PATHS=("/custom" "/path" "/admin" ...)
```

### Change Port Scan List
Edit the `PORTS` variable in `enumerate_network()`:
```bash
PORTS="21,22,80,443,8080,3306,5432"  # Custom ports
```

---

## Output Example

```
=== Network Hunter v1.0 ===
Timestamp: 2026-06-19_14-30-45

My IP:   10.0.0.72
Gateway: 10.0.0.1
DNS:     8.8.8.8
Network: 10.0.0.0/24
================================

Live hosts discovered: 5

================================
ENUMERATED HOSTS & SERVICES
================================

10.0.0.28 | 22/tcp(ssh)
10.0.0.31 | 445/tcp(microsoft-ds)
10.0.0.55 | 21/tcp(ftp),80/tcp(http)
10.0.0.100 | 22/tcp(ssh),3389/tcp(ms-wbt-server)
10.0.0.150 | 445/tcp(microsoft-ds),3389/tcp(ms-wbt-server)

Scan complete and saved to loot
```

---

## Red Team Workflow

1. **Reconnaissance** → Run Network Scan to map targets
2. **Service Enumeration** → Run individual sprays or Run All
3. **Credential Testing** → FTP spray for quick wins
4. **Service Detection** → SSH/SMB/HTTP modules guide next steps
5. **Post-Exploitation** → Use post-recon guidance for deeper attacks
6. **Exfiltration** → Findings auto-uploaded to C2 or reviewed locally

---

## Author

**Hackazillarex**

## License

For authorized red team engagements only.

