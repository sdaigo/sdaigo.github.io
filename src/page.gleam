import birl
import commonmark as cm
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import handles
import handles/ctx
import simplifile.{read, write}

pub fn main() {
  let assert Ok(_) =
    build_html()
    |> string_builder.to_string
    |> write(to: "dist/index.html")
}

fn build_html() {
  let assert Ok(template) = read(from: "templates/template.html")
  let assert Ok(source) = read(from: "content/page.md")

  let content =
    source
    |> cm.render_to_html

  let now = birl.now()

  let assert Ok(template) = handles.prepare(template)
  let assert Ok(html) =
    handles.run(
      template,
      ctx.Dict([
        ctx.Prop("content", ctx.Str(content)),
        ctx.Prop("timestamp", ctx.Str(now |> birl.to_iso8601)),
        ctx.Prop("year", ctx.Str(now |> current_year)),
      ]),
      [],
    )

  html
}

fn current_year(now) {
  now
  |> birl.to_date_string
  |> string.split("-")
  |> list.first
  |> result.unwrap("2020")
}
