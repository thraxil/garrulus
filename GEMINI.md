
# Garrulus

This is a Phoenix application.

## Development Setup

1.  **Install dependencies:**
    ```bash
    make deps
    ```

2.  **Set up the database:**
    ```bash
    make setup
    ```
    This will create the database, run migrations, and seed the database.

## Running the Application

To start the Phoenix server, run:

```bash
make server
```

You can then visit [`http://localhost:4000`](http://localhost:4000) in your browser.

## Running Tests

To run the test suite, use the following command from the project root:

```bash
make test
```

The CI runs the tests with `mix test --trace --slowest 10`.

## Linting and Formatting

This project uses the standard Elixir formatter. To format the code, run:

```bash
make format
```
