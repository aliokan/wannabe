package client;

import game.Protocol;
import tink.state.State;

class Client {
  static function main() {
    switch window.location.hash {
      case '':
        window.location.hash = new PlayerId();
      default:
    }

    final self:State<Player> = new State({
      id: new PlayerId(),
      name: "",
      house: null,
      ready: false,
    });

    final remote = client.service.Remote.connect(
      "ws://localhost:2751", 
      self.value, 
      window.location.hash.substr(1)
    ).handle(function (o) switch o {
      case Success(gameConnection):
        final game = gameConnection.game;
        final send = gameConnection.send;
        final gameSession = new GameSession({ game: game, self: self });

        game.observables.players.bind(v -> switch v.first(p -> p.id == self.value.id) {
          case Some(p): self.set(p);
          case None: alert("We got kicked");
        });

        function setPlayerDetails(name:String, house:House)
          send(SetPlayerDetails(name, house));
        
        function setReady(isReady:Bool)
          send(SetReady(isReady));

        Renderer.mount(
          document.body,
          coconut.Ui.hxx(
            <Isolated>
              {
                if (game.running) <GameView game={gameSession} />
                else if (self.value.house == null) <StartView setPlayerDetails={setPlayerDetails} />
                else <LobbyView players={game.players} self={self.observe()} setReady={setReady} />
              }
            </Isolated>
          )
        );        
      case Failure(e): alert(e.message);
    });
    // var players:Array<Player> = [
    //   { id: new PlayerId(), name: 'Gene' },
    //   { id: new PlayerId(), name: 'Hector' },
    //   { id: new PlayerId(), name: 'Arsen' },
    //   { id: new PlayerId(), name: 'Juraj' },
    // ];

    // var size = 20;

    // var tiles = [TileKind.TLand, TileKind.TLand, TileKind.TLand, TileKind.TLava];

    // var game = new GameSession({
    //   self: players[0],
    //   game: new Game({
    //     id: 'yo',
    //     width: size,
    //     players: players,
    //     units: [
         
    //     ],
    //     tiles: [
    //       for (s in 0...size * size)
    //         new Tile({ kind: tiles[Std.random(tiles.length)]})
    //     ],
    //   })
    // });

    // // trace(Std.string(haxe.Json.parse(haxe.Json.stringify(JoinRoom('fo', { id: new PlayerId(), name: 'foobar' })))));
  }
}