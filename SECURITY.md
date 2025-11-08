# Security Policy

## Reporting Security Vulnerabilities

**DO NOT** report security vulnerabilities through public GitHub issues.

Email: security@appyfly.com  
Response time: Within 48 hours

### What to Include

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact assessment
4. Affected versions
5. Suggested fix (optional)

## Security Measures

### API Security

#### Authentication
- JWT tokens expire after 1 hour
- Refresh tokens rotate on each use
- Rate limiting: 100 requests/minute per user
- Brute force protection with exponential backoff

#### Data Protection
- All API communication uses HTTPS (TLS 1.3)
- Passwords hashed with bcrypt (12 rounds)
- Sensitive data encrypted at rest (AES-256-GCM)
- PII automatically purged after 90 days

### Mobile App Security

#### Code Protection
- Release builds use code obfuscation
- API keys stored in secure storage
- Certificate pinning for API communication
- No sensitive data in logs

#### Local Storage
- User credentials in Keychain (iOS) / Keystore (Android)
- Encrypted local database
- Automatic session timeout after 30 minutes

### Infrastructure Security

#### Firebase
```javascript
// Firestore rules enforce user isolation
match /generations/{generationId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

#### Cloud Storage
- Signed URLs with 1-hour expiration
- User-scoped storage buckets
- Automatic malware scanning

### Third-Party Services

| Service | Security Measures |
|---------|------------------|
| Replicate API | Token rotation every 90 days |
| Firebase | 2FA required for admin accounts |
| Custom Cat | Webhook signature verification |
| Google Cloud | VPC with private endpoints |

## Security Headers

Production API responses include:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'; img-src 'self' https:; script-src 'self'
```

## Dependency Management

### Automated Scanning
- Daily vulnerability scans via Dependabot
- Weekly dependency updates
- Critical patches applied within 24 hours

### Review Process
```bash
# Check Flutter packages
flutter pub audit

# Check Node dependencies
npm audit

# Check for secrets
gitleaks detect
```

## Incident Response

### Severity Levels

| Level | Response Time | Examples |
|-------|--------------|----------|
| Critical | 2 hours | Data breach, authentication bypass |
| High | 24 hours | Privilege escalation, XSS |
| Medium | 72 hours | Information disclosure |
| Low | 1 week | Best practice violations |

### Response Process

1. **Contain** - Isolate affected systems
2. **Assess** - Determine impact and scope
3. **Notify** - Alert affected users within 72 hours
4. **Remediate** - Deploy fixes and patches
5. **Review** - Post-mortem and process improvements

## Compliance

### GDPR Compliance
- User consent for data processing
- Right to deletion implemented
- Data portability via export API
- Privacy policy updated quarterly

### Data Retention
- User images: 30 days
- Generation metadata: 1 year
- Analytics data: 2 years
- Payment records: 7 years (legal requirement)

## Security Checklist for Developers

Before each release:
- [ ] No hardcoded secrets in code
- [ ] All user input validated and sanitized
- [ ] SQL injection prevention via parameterized queries
- [ ] XSS protection in all outputs
- [ ] CSRF tokens for state-changing operations
- [ ] Proper error handling (no stack traces to users)
- [ ] Audit logs for sensitive operations
- [ ] Security headers configured
- [ ] Dependencies updated and scanned
- [ ] Penetration testing for major releases

## Contact

Security Team: security@appyfly.com  
Bug Bounty Program: https://appyfly.com/security/bug-bounty

---

Last security audit: October 2024  
Next scheduled audit: January 2025