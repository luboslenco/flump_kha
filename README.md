# flump_kha

Rough port of [Flump](http://threerings.github.io/flump/) animation library from [Flambe](https://github.com/aduros/flambe) to Haxe [Kha](https://github.com/KTXSoftware/Kha)

## Usade

Creating movie player:

    var library = new flump.Library("test_library"); // JSON blob
    var moviePlayer = new flump.MoviePlayer(library);
    moviePlayer.loop('walk');
    var entity = new flump.Entity().add(moviePlayer);
    

In update loop call:

    entity.update();
    
In render loop call:

    flump.Sprite.render(entity, graphics); 
