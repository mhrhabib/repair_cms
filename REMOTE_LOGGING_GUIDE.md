# Remote Logging Setup - RepairCMS

## Overview
Talker logging has been integrated to help debug printer issues remotely. Your client can now share logs with you from anywhere in the world.

## How It Works

### 1. **All Printer Operations Are Logged**
Every print attempt now logs:
- Which printer IP is being used
- Which strategy is attempted (Strategy 1, 2, or 3)
- Connection status
- Success or failure with detailed error messages
- PDF file sizes and data sent

### 2. **Viewing Logs (Client Side)**
Navigate to the Logs Viewer screen:
```dart
context.push(RouteNames.logsViewer);
// or: context.go('/logsViewer');
```

The logs screen shows:
- ✅ Success messages (green)
- ⚠️ Warnings (yellow)
- ❌ Errors (red)
- 📘 Info messages (blue)
- 🐛 Debug details (gray)

### 3. **Sharing Logs**
Client can tap the **Share button** (top-right) to export all logs as text.
They can then send you the logs via:
- WhatsApp
- Email
- Telegram
- Any messaging app

### 4. **Reading Logs Remotely**
You'll receive logs formatted like:
```
[2026-01-02 15:30:45] [PrinterIP: 192.168.0.160:9100] Starting A4 print job with 45628 bytes
[2026-01-02 15:30:45] [Strategy1] Connecting to 192.168.0.160:9100
[2026-01-02 15:30:46] [Strategy1] Sending pure PDF (45628 bytes)
[2026-01-02 15:30:47] ✅ SUCCESS with Strategy 1
```

## Adding Log Viewer to Settings Screen

Add this button to your More Settings or Debug menu:

```dart
ListTile(
  leading: Icon(Icons.bug_report),
  title: Text('View Debug Logs'),
  subtitle: Text('For troubleshooting printer issues'),
  onTap: () => context.push(RouteNames.logsViewer),
)
```

## Testing the Logger

1. **Install packages:**
   ```bash
   flutter pub get
   ```

2. **Test print from client's HP printer**

3. **Open Logs Viewer** - you'll see all strategies attempted

4. **Share logs** - client sends to you

5. **Analyze** - you see exactly which strategy failed and why

## Log Levels

- `talker.info()` - General information
- `talker.debug()` - Detailed debugging info
- `talker.good()` - Success messages (green)
- `talker.warning()` - Warnings (yellow)
- `talker.error()` - Errors (red)
- `talker.critical()` - Critical failures

## Automatic Cleanup

Logs are stored in memory with a max of 1000 items. Client can manually clear logs using the delete button in the logs screen.

## Privacy Note

Logs only contain:
- Printer IP addresses
- Print job metadata
- Error messages
- No customer data or sensitive information

## Example Debugging Scenario

**Client reports:** "HP printer not working"

**Your process:**
1. Ask client to open "Debug Logs" in app
2. Ask them to try printing
3. Client taps "Share" button
4. Client sends you the log text

**You receive:**
```
[Strategy1] Error: SocketException: Connection refused
[Strategy2] Error: SocketException: Connection refused  
[Strategy3] Error: SocketException: Connection refused
```

**Diagnosis:** Firewall blocking port 9100 or printer offline

---

## Next Steps

1. Add a "Debug Logs" button to the More Settings screen
2. Test with client's printer
3. Have client share logs when issues occur
4. Analyze remotely and provide solutions

This eliminates the need for TeamViewer or being physically present!
