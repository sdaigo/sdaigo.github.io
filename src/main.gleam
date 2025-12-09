import gleam/io
import gleam/result
import gleam/string
import process.{type BuildError, FileError, TemplateError}
import simplifile.{write}

pub fn main() {
  case run() {
    Ok(_) -> io.println("✨ Successfully built site!")
    Error(err) -> {
      case err {
        FileError(path, detail) -> {
          io.print_error(
            "Failed to read file: " <> path <> ": " <> string.inspect(detail),
          )
        }
        TemplateError(stage, detail) -> {
          io.print_error(
            "Failed to build template: " <> stage <> ": " <> detail,
          )
        }
      }
    }
  }
}

fn run() -> Result(Nil, BuildError) {
  // prepare dist directory
  use _ <- result.try(
    simplifile.create_directory_all("dist")
    |> result.map_error(fn(e) { FileError("dist", e) }),
  )

  let output_path = "dist/index.html"

  use html <- result.try(
    process.build_html_from_file()
    |> result.map_error(fn(e) {
      TemplateError("build_html_from_file", string.inspect(e))
    }),
  )
  use _ <- result.try(
    write(html, to: output_path)
    |> result.map_error(fn(e) { FileError(output_path, e) }),
  )

  Ok(Nil)
}
