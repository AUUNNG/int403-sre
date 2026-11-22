# Data Center Comms & Postmortem Style

Use this template and style when drafting Discord messages to P'Bas (`@zabastien`) or updating `forms/post-mortem/`.

## Discord Message Style (`@zabastien`)

- **Tone**: Direct, polite-casual Thai (`พี่บาสคับ @zabastien`, `ว่างไหมคับ`), without formal boilerplate.
- **Format**: Single `text` code block with zero nested backticks.
- **Structure**:
  1. Greeting + `@zabastien` + proposed date/time window question.
  2. Evidence & symptoms (`IP`, `CMM Health`), grouped by component using `timestamp | event` bullets.
  3. Short numbered list of on-site actions (`อยากเข้าไป`).
  4. Spare-parts availability question listing exact `FRU` part numbers if needed.
  5. Short closing (`ขอบคุณครับ`).

### Reference Template

```text
พี่บาสคับ @zabastien

วัน<วัน>ที่ <วันที่> เวลา <เวลา> พี่บาสว่างไหมคับ

อาการและหลักฐานที่พบ (IP <IP>, CMM Health: <สถานะ>):
1. ปัญหา <อุปกรณ์/ระบบ>:
   - <DD Mon HH:MM:SS> | <เหตุการณ์>
   - <ข้อความ error>

อยากเข้าไป
1. <งานที่ 1>
2. <งานที่ 2>

ถ้าตรวจเช็คแล้ว <อุปกรณ์> เสียจริง พี่บาสพอจะมีสำรองไหมคับ ของเดิมใช้
- <รุ่นและ FRU>

ขอบคุณครับ
```

## Postmortem & Incident Record (`forms/post-mortem/`)

- Keep `.xlsx` and `.md` (`incident-record-*.md`, `postmortem-*.md`) in sync without altering table headers or schemas.
- Always use full Thai names with `นาย` prefix (`นายยุทธภูมิ ฮาบพนม`, `นายภัคพล ธีรชัยศุภกิจ`, `นายศุภฤกษ์ กมลเนตร`).
