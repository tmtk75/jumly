module Jumly
  module Grammer
    module SequenceData
      found = <<-EOF
@found "A"
@found "B"
      EOF

      message = <<-EOF
@found "A", ->
  @message "do", "B"
      EOF

      create = <<-EOF
@found "A", ->
  @create "B"
      EOF

      destroy = <<-EOF
@found "A", ->
  @create "B"
  @destroy "B"
      EOF

      reply = <<-EOF
@found "A", ->
  @message "do", "B", ->
    @reply "", "A"
      EOF

      ref = <<-EOF
@found "A", ->
  @message "do", "B", ->
  @ref "Another"
      EOF

      lost = <<-EOF
@found "A", ->
  @message "do", "B", ->
diag["A"].lost()
      EOF

      loop = <<-EOF
@found "A", ->
  @loop ->
    @message "do", "B", ->
      EOF

      alt = <<-EOF
@found "A", ->
 @alt {
  "[x > 0]": -> @message "do", "B"
  "[x < 0]": -> @message "do", "C"
 }
      EOF

      reactivate = <<-EOF
@found "A", ->
  @message "do", "B", ->
    @reactivate "do", "C"
  EOF

      iconify = <<-EOF
@found "A", ->
  @message "do", "B", ->
    @message "do", "C"
  @beforeCompose (e, diag) ->
    diag.A.iconify "view"
    diag.B.iconify "controller"
    diag.C.iconify "entity"
      EOF
    
      DATA = {found: found, message: message, create: create, destroy: destroy,
              reply: reply, lost: lost, loop: loop, ref: ref,
              alt: alt, reactivate: reactivate, iconify: iconify}
    end
     

    module UsecaseData
      usecase = <<-EOF
@usecase "Browsing"
      EOF
      USECASE = usecase
    end

    module ClassData
      def_ = <<-EOF
@def "Browser":
  stereotype:"platform"
  attrs     :["version", "name"]
  methods   :["render HTML", "open file", "run script"]
      EOF
    end
  end
end
