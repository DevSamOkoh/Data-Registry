# Data Registry

A registry system for managing and tracking data assets across different environments.

## Features

- Environment-specific settings (Mainnet, Testnet)
- Logging and history tracking
- Coverage and cost reporting
- Node.js dependency management

## Project Structure

```
.
├── settings/           # Environment configuration files
├── .cache/             # Cached data (ignored)
├── logs/               # Log files (ignored)
├── node_modules/       # Node.js dependencies (ignored)
├── history.txt         # Change history
├── .gitignore          # Git ignore rules
├── README.md           # Project documentation
└── ...                 # Other source files
```

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/data-registry.git
   cd data-registry
   ```

2. **Install dependencies:**
   ```sh
   npm install
   ```

3. **Run the project:**
   ```sh
   npm start
   ```

## Development

- Configuration files are located in the `settings/` directory.
- Logs and cache are ignored by Git as specified in `.gitignore`.
- Use `npm test` to run tests (if available).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License.
