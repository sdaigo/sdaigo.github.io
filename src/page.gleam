import commonmark as cm
import gleam/string_builder
import handles
import handles/ctx
import simplifile.{read, write}

pub fn main() {
  let assert Ok(template) = read(from: "templates/template.html")
  let assert Ok(source) = read(from: "src/page.md")

  let content =
    source
    |> cm.render_to_html

  let assert Ok(tmpl) = handles.prepare(template)
  let assert Ok(html) = handles.run(tmpl, ctx.Str(content), [])

  let assert Ok(_) =
    html |> string_builder.to_string |> write(to: "public/index.html")
}
