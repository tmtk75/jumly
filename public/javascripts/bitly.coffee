Bitly =
  shorten: (args)->
    bitly = "http://api.bit.ly/shorten?version=2.0.1&login=tmtk75&apiKey=R_39bc09b13aac4481bc526f946f7d1538&longUrl=#{encodeURIComponent args.url}&callback=?"
    $.getJSON bitly, (res)-> if res.errorCode then args.failure(res) else args.success(res)

window.Bitly = Bitly