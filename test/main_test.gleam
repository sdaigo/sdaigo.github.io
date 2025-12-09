import birl
import gleeunit
import gleeunit/should
import process

pub fn main() {
  gleeunit.main()
}

pub fn generate_html_content_test() {
  let template = "{{ content }} - {{ year }}"
  let markdown = "Hello, This is a test."

  let now = birl.from_unix(1_735_689_600)

  let result = process.generate_html(template, markdown, now)

  result
  |> should.be_ok
  |> should.equal("<p>Hello, This is a test.</p>\n - 2025")
}

pub fn current_year_test() {
  // 2025-01-01
  let time = birl.from_unix(1_735_689_600)

  process.current_year(time)
  |> should.equal(2025)
}
