# Contributing to PrintCraft AI

Thank you for your interest in contributing to PrintCraft AI! This guide will help you get started.

## Code of Conduct

Be respectful, inclusive, and professional. We're building something great together.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Run setup script: `./scripts/setup-dev-environment.sh`
4. Create a feature branch: `git checkout -b feature/amazing-feature`
5. Make your changes
6. Submit a pull request

## Development Setup

```bash
# Clone repository
git clone https://github.com/yourusername/print-craft-ai.git
cd print-craft-ai

# Run setup script
./scripts/setup-dev-environment.sh

# Start developing
cd pod_app
flutter run
```

## Code Standards

### Flutter/Dart
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `dart format .` before committing
- Ensure `flutter analyze` shows no issues
- Maintain 80% test coverage

### Commit Messages

Follow conventional commits format:
```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, semicolons, etc)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```bash
feat(generation): add batch processing support
fix(auth): resolve token refresh race condition
docs(api): update endpoint documentation
test(models): add unit tests for generation model
```

### Pull Request Process

1. **Update documentation** for any changed functionality
2. **Add tests** for new features
3. **Ensure CI passes** - all tests and checks must pass
4. **Keep PRs focused** - one feature/fix per PR
5. **Write clear descriptions** - explain what and why

#### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix or feature that breaks existing functionality)

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
```

## Testing

### Running Tests
```bash
# All tests
./scripts/run-tests.sh

# Unit tests only
./scripts/run-tests.sh --unit

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Writing Tests
```dart
// Good test example
test('generateImage returns valid model on success', () async {
  // Arrange
  final service = MockGenerationService();
  when(service.generateImage(any)).thenAnswer(
    (_) async => GenerationModel(/* ... */),
  );
  
  // Act
  final result = await service.generateImage('test prompt');
  
  // Assert
  expect(result.status, GenerationStatus.succeeded);
  expect(result.imageUrl, isNotEmpty);
});
```

## Project Structure

```
print-craft-ai/
├── pod_app/           # Flutter application
│   ├── lib/          # Source code
│   │   ├── core/     # Core functionality
│   │   └── features/ # Feature modules
│   └── test/         # Tests
├── .claude/          # Claude Skills
├── .github/          # GitHub workflows
├── scripts/          # Development scripts
└── docs/             # Documentation
```

## Adding Features

### 1. Plan Your Feature
- Discuss in GitHub Issues first
- Get feedback on approach
- Consider backwards compatibility

### 2. Implement Feature
- Follow existing patterns
- Add comprehensive tests
- Update relevant documentation

### 3. Test Thoroughly
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for workflows
- Manual testing on both platforms

### Example: Adding a New AI Model
```dart
// 1. Add model configuration
class NewModel extends AIModel {
  const NewModel() : super(
    id: 'new-model/v1',
    name: 'New Model',
    costPerImage: 0.05,
    averageTime: Duration(seconds: 30),
  );
}

// 2. Add to model registry
final models = {
  // ... existing models
  AIModelType.newModel: NewModel(),
};

// 3. Update UI to include new model
// 4. Add tests
// 5. Update documentation
```

## Documentation

### Where to Document
- **Code**: Inline documentation for complex logic
- **README**: Setup and basic usage
- **API.md**: Detailed API documentation
- **Skills**: Implementation patterns in `.claude/skills/`

### Documentation Style
```dart
/// Generates a POD-optimized image using AI.
/// 
/// The [prompt] describes the desired image.
/// Optional [style] applies predefined styling.
/// 
/// Returns a [GenerationModel] with the result.
/// 
/// Example:
/// ```dart
/// final result = await generateImage(
///   prompt: 'Sunset landscape',
///   style: 'watercolor',
/// );
/// ```
```

## Performance Considerations

- Profile before optimizing
- Consider widget rebuilds
- Optimize image loading
- Monitor memory usage
- Test on low-end devices

## Security

- Never commit secrets
- Validate all inputs
- Use secure storage for sensitive data
- Follow OWASP guidelines
- Report security issues privately

## Getting Help

- **Discord**: [Join our community](https://discord.gg/appyfly)
- **Issues**: Use GitHub Issues for bugs/features
- **Discussions**: GitHub Discussions for questions
- **Email**: dev@appyfly.com for direct contact

## Recognition

Contributors are recognized in:
- Release notes
- Contributors file
- Annual contributor spotlight

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.