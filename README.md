# 🚀 Stream vs Static API Demo (Flutter)

A simple Flutter application to demonstrate **different data delivery mechanisms** in APIs:

- **SSE (Server-Sent Events)** – real-time streaming like LLM responses
- **NDJSON (Newline Delimited JSON)** – streaming via line-by-line JSON objects
- **Static API** – traditional REST API returning full data once

---

## 📸 Preview

This app shows how text can be streamed and appended dynamically inside Flutter, allowing you to compare:
| Mode | Format | Description |
|------|---------|-------------|
| **SSE Stream** | `text/event-stream` | Data arrives as events with `data: {...}` |
| **NDJSON Stream** | `application/x-ndjson` | Data arrives as newline-delimited JSON objects |
| **Static Response** | `application/json` | Data arrives once when request completes |

---

## 🛠️ Tech Stack

- **Flutter** (3.5+)
- **Dio** for HTTP and stream handling
- **Material 3 UI**
- Example backend: [https://sse-static-api-example-production.up.railway.app](https://sse-static-api-example-production.up.railway.app)

---

## 🧩 Features

✅ Compare **SSE**, **NDJSON**, and **Static** APIs side by side  
✅ Real-time text streaming using `setState` updates  
✅ Pretty UI using Material 3  
✅ Safe async handling for each API type  
✅ Works with any streaming endpoint

---

## 📦 Installation

Clone the repo:

```bash
git clone https://github.com/pramek008/flutter-stream-vs-static-demo.git
cd flutter-stream-vs-static-demo
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

---

## 🌐 Backend API Reference

This demo uses a hosted example backend at:

```
https://sse-static-api-example-production.up.railway.app
```

Available endpoints:

- `/stream-sse` → SSE stream (text/event-stream)
- `/stream-ndjson` → NDJSON stream (application/x-ndjson)
- `/api/data` → Static JSON response

---

## 🧠 Concept Summary

| Type           | Protocol                   | Pros                                   | Cons                       |
| -------------- | -------------------------- | -------------------------------------- | -------------------------- |
| **SSE**        | HTTP long-lived connection | Easy to implement for 1-way updates    | Limited to server → client |
| **NDJSON**     | HTTP stream                | Simple format, works with JSON parsers | Not browser-native         |
| **Static API** | Standard HTTP request      | Simple and reliable                    | Not real-time              |

---

## 🧑‍💻 Author

**Eka Pramudya**
Flutter & Backend Developer
💡 Building streaming and AI-driven Flutter apps

---

## 🪪 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
