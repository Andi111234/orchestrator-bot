# Orchestrator Bot - Unified Refactor

This branch contains a unified refactor of all three EAs (orchestrator.mq4, master_AUDCAD.mq4, slave_AUDUSD.mq4) with shared libraries for step computation, graphics, and cooldown logic.

## Quick Start

### Download
```bash
# Clone the repository and checkout this branch
git clone https://github.com/Andi111234/orchestrator-bot.git
cd orchestrator-bot
git checkout copilot/fix-216591429-1088335663-9d19154a-8159-4efa-a591-63b341c47bd5

# Or download as ZIP from GitHub
```

### Compile
1. Open MetaEditor (MT4)
2. Open each EA file:
   - `orchestrator.mq4`
   - `master_AUDCAD.mq4`
   - `slave_AUDUSD.mq4`
3. Press F7 or click "Compile" button
4. Verify no errors in the "Errors" tab

All three EAs should compile cleanly without errors.

### Test
1. Open MT4 Strategy Tester (Ctrl+R)
2. Select one of the compiled EAs
3. Choose symbol, timeframe, and date range
4. Click "Start" to run backtest

## Key Features

### Shared Libraries
- **steps_unified.mqh**: Unified step computation (6 ranges × 5 PR flags) with cached globals
- **graphics_common.mqh**: Common graphics helpers for chart objects
- **sovetnikov_light.mqh**: Compatibility layer (already present)

### New Input Parameters

#### orchestrator.mq4
- `OpenCooldownSec` (default: 2) - Cooldown between re-entries in seconds (0 = disabled)
- `UseMN1FromD1` (default: true) - Feed MN1 analytics from D1(20) instead of MN1 bars
- `DaysToAnalyze_D1` (default: 20) - Days of D1 to use for MN1 proxy when UseMN1FromD1=true

#### master_AUDCAD.mq4 & slave_AUDUSD.mq4
- `OpenCooldownSec` (default: 2) - Cooldown between re-entries in seconds (0 = disabled)

### Performance Improvements
- Step computation moved from OnTick to OnTimer (60-second refresh)
- Cached step values reduce file I/O per tick
- Graphics helpers reduce redundant ObjectCreate/ObjectSet calls

### Code Quality
- All files now UTF-8 encoded (no more mojibake on GitHub)
- Unified step computation logic across all three EAs
- Consistent cooldown implementation
- Minimal code duplication

## Visual Validation Checklist

After attaching an EA to a chart:

1. ✅ **Step lines visible** - Horizontal lines showing next entry levels
2. ✅ **Price labels** - Text objects displaying step prices
3. ✅ **Cache refresh** - Check Expert log for "[Steps_OnTimer]" messages every 60 seconds
4. ✅ **Cooldown working** - Re-entries respect OpenCooldownSec delay (visible in log)

## File Structure

```
orchestrator-bot/
├── orchestrator.mq4           (Main EA, UTF-8)
├── master_AUDCAD.mq4          (Master pair EA, UTF-8)
├── slave_AUDUSD.mq4           (Slave pair EA, UTF-8)
├── steps_unified.mqh          (Shared step computation)
├── graphics_common.mqh        (Shared graphics helpers)
├── sovetnikov_light.mqh       (Compatibility layer)
└── README.md                  (This file)
```

## Troubleshooting

### Compilation Errors
- **"Cannot open include file"**: Ensure all .mqh files are in the same directory as .mq4 files
- **"Redefinition"**: Check that you're using the latest version of all files from this branch
- **"Unknown identifier"**: Verify all includes are at the top of the file

### Runtime Issues
- **No step lines**: Check that at least one position is open for the EA's magic number
- **Steps not updating**: Verify EventSetTimer(60) is called in OnInit
- **Cooldown not working**: Check OpenCooldownSec > 0 in EA inputs

## What Changed

### orchestrator.mq4
- Added shared library includes
- Added cooldown infrastructure (arrays, helpers, checks on OrderSend)
- Replaced inline step computation with OnTimer cache
- Replaced graphics code with Ensure* helpers
- Added MN1/D1 analytics toggle

### master_AUDCAD.mq4 & slave_AUDUSD.mq4
- Converted from UTF-16 to UTF-8
- Added shared library includes
- Integrated Steps_OnTimer into existing OnTimer
- Removed duplicate step computation code
- Cooldown already present and functional

## Support

For issues or questions:
1. Check the Errors tab in MetaEditor
2. Check the Expert log in MT4 Terminal
3. Review this README
4. Open an issue on GitHub with error details

---

**Note**: This refactor maintains behavior equivalence with the original code. All strategy parameters, lot tables, equity close logic, and trailing remain unchanged.
