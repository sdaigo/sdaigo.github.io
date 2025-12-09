import birl
import gleam/int
import gleam/result
import gleam/string
import gleam/string_tree
import handles
import handles/ctx
import jot
import simplifile.{read}

pub type BuildError {
  FileError(path: String, detail: simplifile.FileError)
  TemplateError(stage: String, detail: String)
}

pub fn generate_html(
  template_str: String,
  source_str: String,
  now: birl.Time,
) -> Result(String, BuildError) {
  let content = source_str |> jot.to_html
  use template <- result.try(
    handles.prepare(template_str)
    |> result.map_error(fn(e) { TemplateError("Prepare", string.inspect(e)) }),
  )

  use html <- result.try(
    handles.run(
      template,
      ctx.Dict([
        ctx.Prop("content", ctx.Str(content)),
        ctx.Prop("timestamp", ctx.Str(now |> birl.to_iso8601)),
        ctx.Prop("year", ctx.Str(now |> current_year |> int.to_string)),
      ]),
      [],
    )
    |> result.map_error(fn(e) { TemplateError("Run", string.inspect(e)) }),
  )

  Ok(html |> string_tree.to_string)
}

pub fn build_html_from_file() -> Result(String, BuildError) {
  let template_path = "templates/template.html"
  use template <- result.try(
    read(from: template_path)
    |> result.map_error(fn(e) { FileError(template_path, e) }),
  )

  let content_path = "content/page.md"
  use source <- result.try(
    read(from: content_path)
    |> result.map_error(fn(e) { FileError(content_path, e) }),
  )

  generate_html(template, source, birl.now())
}

pub fn current_year(now) {
  now
  |> birl.get_day
  |> fn(d) { d.year }
}
