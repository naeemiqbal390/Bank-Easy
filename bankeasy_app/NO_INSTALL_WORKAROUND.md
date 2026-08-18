# Building this app with no software installed on your PC

Everything below happens in a browser tab. Nothing is downloaded to
your work PC at any point — GitHub's cloud servers do the actual
compiling.

## 1. Get the code onto GitHub (5 minutes, browser only)

1. Create a free account at github.com if you don't have one.
2. Click "New repository", name it `bankeasy`, keep it Private.
3. On the empty repo page, click "uploading an existing file" and
   drag in this entire `bankeasy_app` folder (including the hidden
   `.github` folder — most browsers include it automatically when you
   drag the whole folder; if it's missing, upload it separately).
4. Commit the upload.

## 2. Let it build itself

The `.github/workflows/build.yml` file included in this project is a
recipe GitHub runs automatically on its own servers every time you
upload new code. You don't trigger anything manually the first time —
uploading the code already triggers it.

To watch it or re-run it by hand: go to the **Actions** tab on your
repo. You'll see the build running (takes 3–6 minutes). When it's
green/finished, click into the run, scroll to **Artifacts**, and
download `bankeasy-release-build` — inside is a real `.apk` (for
testing) and `.aab` (for Play Store upload).

## 3. Test it — on your phone, not your PC

Download the `.apk` file directly from GitHub on your **Android
phone's browser**, not your PC. Tap it to install (Android will ask
you to allow installs from your browser the first time — that's a
phone setting, not a PC install). This is the actual app running,
not a mockup.

## 4. If you need an interactive terminal for anything

Open a **Codespace** on your repo (button on the repo's main page:
"Code" → "Codespaces" → "Create codespace"). This opens a full Linux
machine with a code editor, right in your browser tab. Nothing
installs locally — you're remote-controlling a cloud computer. Use
this if you ever need to run a one-off command (like generating a
Play Store signing key — see below) rather than the automated
pipeline.

## 5. Play Store submission — the account decision

Registration is a one-time $25 fee, done at play.google.com/console,
entirely in a browser. Two account types, and this app's situation
makes the tradeoff worth knowing upfront:

- **Personal account**: no extra paperwork to start, but Google now
  requires a closed test with a minimum number of real testers over
  roughly two weeks before the app can go public. Workable, just adds
  time before launch.
- **Organization account**: skips that closed-testing requirement,
  but needs a D-U-N-S number (a business identifier — takes days to
  weeks to obtain if you don't already have one) and is the account
  type Google specifically calls out for apps touching finance/banking
  categories. Given BankEasy sits adjacent to that category even
  though it doesn't move money, this is the safer long-term choice —
  but it's slower to set up initially.

Either way, once you have an AAB from step 2, uploading it to Play
Console, filling in the store listing, and submitting for review all
happens in the browser — no local tooling required at any point.

## One thing already handled for you

This project only contains Dart source code — the native Android
project files (the `android/` folder) are normally generated on your
machine by running `flutter create`. Since you don't have Flutter
locally, the build workflow generates that folder itself, in the
cloud, as its first step (`flutter create . --platforms=android`)
before compiling. You don't need to do anything for this — it's
already wired into `build.yml`. It's worth knowing it's happening
in case a future build step ever needs adjusting.

## One thing to plan for: your signing key

The AAB needs to be signed with a release key that's yours to keep —
lose it and you can never publish an update to the same app listing
again. Generating one needs the `keytool` command (comes with the
JDK). Do this once, inside a Codespace (step 4), not on your PC:

```
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bankeasy
```

Download the resulting `release-key.jks` file from the Codespace to
somewhere safe (a password manager or encrypted drive) — it's the one
piece of this whole process that truly can't be regenerated if lost.
