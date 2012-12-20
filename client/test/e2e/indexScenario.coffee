describe "my app", ->
  beforeEach ->
    browser().navigateTo "/"

  it "publicly accessible and default route to be /", ->
    expect(browser().location().path()).toBe "/"