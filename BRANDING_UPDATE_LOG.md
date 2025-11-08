# Branding Update Log

## Overview
Updated all domain references from printcraft.ai to appyfly.com while maintaining the project name "PrintCraft AI" for internal use.

## Brand Structure
- **Project Name**: PrintCraft AI (internal development name)
- **App Store Brand**: Appy Fly
- **Parent Company**: Tekfly Ltd (Company Number 15798932)
- **Domain**: appyfly.com

## Changes Made

### 1. Email Addresses
- ✅ `security@printcraft.ai` → `security@appyfly.com`
- ✅ `dev@printcraft.ai` → `dev@appyfly.com`

### 2. API URLs
- ✅ Production API: `https://api.appyfly.com/v1`
- ✅ Staging API: `https://staging-api.appyfly.com/v1`
- ✅ Storage: `https://storage.appyfly.com`
- ✅ Status Page: `https://status.appyfly.com`

### 3. Webhook URLs
- ✅ Updated webhook endpoints to use appyfly.com domain

### 4. Package Names
- ✅ NPM: `@appyfly/sdk`
- ✅ Dart/Flutter: `appyfly_sdk`
- ✅ Android Package: `com.appyfly.app`

### 5. SDK Class Names
- ✅ `PrintCraftClient` → `AppyFlyClient`

### 6. Other Updates
- ✅ Discord invite: `https://discord.gg/appyfly`
- ✅ Bug bounty URL: `https://appyfly.com/security/bug-bounty`
- ✅ HTTP headers: `x-appyfly-signature`

## Files Modified

1. **SECURITY.md** - Email and website URLs
2. **CLAUDE.md** - Security email
3. **CONTRIBUTING.md** - Dev email and Discord
4. **docs/API.md** - All API URLs, SDK names, and examples
5. **.github/workflows/deploy-production.yml** - Android package name
6. **pod_app/lib/config/api_endpoints.dart** - API endpoints (already correct)
7. **scripts/deploy.sh** - API URLs (already correct)

## No Changes Required

The following remain unchanged as they represent the internal project name:
- Project folder: `print-craft-ai`
- Internal references to "PrintCraft AI"
- Git repository name
- Development documentation titles

## Verification

All public-facing elements now correctly use the appyfly.com domain while maintaining the PrintCraft AI project identity for development purposes.

---

Date: 2024-11-08
Updated by: Claude