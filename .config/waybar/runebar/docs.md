# OSRS Activity Tracker

A Flask-based activity tracker for Old School RuneScape that monitors XP drops via webhook and displays activity status in Waybar.

## Overview

This service receives webhook notifications from an OSRS plugin (like RuneLite) when XP drops occur. It tracks your activity state and signals Waybar to update the status indicator.

## States

| State | Condition | Description |
|-------|-----------|-------------|
| `green` | Active within timeout | Recently received XP drop |
| `red` | Inactive > skill timeout | No XP drops for longer than the skill's configured timeout |
| `idle` | Inactive > 600s | No activity for 10+ minutes |

## Configuration

### skill_config.json

Define custom inactivity timeouts per skill:

```json
{
  "default": 15,
  "mining": 15,
  "fishing": 12,
  "woodcutting": 20
}
```

- **default**: Fallback timeout for unknown skills (seconds)
- **skill_name**: Timeout in seconds for that specific skill

Skills with faster XP drops (like fishing) can have shorter timeouts.

## API Endpoints

### GET /stats

Returns current activity state.

**Response:**
```json
{
  "text": "OSRS - Activity true",
  "class": "green",
  "last_active_seconds_ago": 5,
  "current_skill": "mining",
  "inactive_timeout": 15
}
```

### POST /webhook

Receives notifications from OSRS plugin.

**Request:**
- Content-Type: `application/x-www-form-urlencoded`
- Body: `payload_json=<JSON string>`

#### xp_drop - Mark activity as active

```json
{
  "type": "EXTERNAL_PLUGIN",
  "embeds": [{
    "title": "PlayerName, mining",
    "description": "xp_drop"
  }]
}
```

The skill name is extracted from the title (second element after splitting by comma).

#### xp_stop - Force activity to inactive

Instantly sets the activity state to `red` (inactive).

```json
{
  "type": "EXTERNAL_PLUGIN",
  "embeds": [{
    "description": "xp_stop"
  }]
}
```

Use this to immediately stop tracking activity (e.g., when logging out or taking a break).

## Waybar Integration

The service sends `SIGRTMIN+10` to Waybar every second to trigger a status update.

Example Waybar module configuration:

```json
"custom/osrs": {
  "exec": "curl -s http://localhost:5000/stats",
  "return-type": "json",
  "signal": 10,
  "interval": "once"
}
```

## Running

```bash
python activity.py
```

Server starts on `0.0.0.0:5000`.

## Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `DEFAULT_INACTIVE_SECONDS` | 15 | Default timeout if no config |
| `IDLE_SECONDS` | 600 | Time until idle state (10 min) |
| `WAYBAR_SIGNAL` | `pkill -SIGRTMIN+10 waybar` | Signal command |
