//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Auction {
    address payable public owner;
    // IMPORTANTE: Las subastas requieren de un tiempo de inicio y fin. En solidity, el tiempo es tramposo ya que los timestamp de
    // los bloques son seteados por los mineros y pueden ser manipulados facilmente por ellos. Por ello no es seguro usar la variable
    // global llamada block.timestam. Una buena practica es calcular el tiempo basandose en el numero de bloque. Por ello declaro
    // dos variables globales que me ayudaran a calcular el tiempo de la subasta.
    uint256 public startBlock;
    uint256 public endBlock;

    // El producto a subastar seguramente tenga una descripcion (texto, imagenes, etc) que no conviene guardarlos en la blockcahin
    // ya que es muy caro. Por eso puede utilizar otra solucion desentralizada off-chain como por ejemplo IPFS (interplanetary file system)
    // Y lo que se guarda en la blockchain es un hash de lo guardado en IPFS.
    string public ipfsHash;

    // Tambien declaramos una variable de estado para ver en que estado esta la subasta:
    //
    enum State {
        Started,
        Running,
        Ended,
        Canceled
    }
    State public auctionState;

    // Variable de estado para guardar la maxima apuesta o el valor de venta
    uint256 public highestBindingBid;

    // Variable para almacenar el address del maximo ofertante
    address payable public highestBidder; // tiene que ser payable para que se puedan devolver los fondos si se cancela la subasta o hay una oferta mas alta

    // creo una variable mapping que almacene, para cada ofertante, el address y el valor ofertado
    mapping(address => uint256) public bids;

    // variable para guardar los incrementos de las ofertas
    uint256 bidIncrement;

    constructor() {
        owner = payable(msg.sender); // hay que convertir el sender en payable ya que el owner tiene que recibir eth
        auctionState = State.Running;
        // Por lo mencionado anteriormente como IMPORTANTE. Una buena practica es calcular el tiempo basandose en el numero de bloque.
        // Sabemos que, en ethereum, el tiempo entre bloque y bloque son 50 segundos (se crea un bloque y se añade a la blockchain
        // apoximadamente cada 50 segundos).
        // Inicializo startBlock con el bloque actual ya que quiero iniciar la subasta ahora. Se puede iniciar en un futuro sabiendo que
        // cada bloque se crea cada 50 segundos.
        startBlock = block.number; // block.number es la variable global que devuelve el numero de bloque.
        // Supongamos que queremos que la subasta sea valida por una semana. cuanto deberia valer el endBlock? cuantos bloques de eth se
        // generan en una semana?
        // 60 segundos en 1 min * 60 minutos en una hora * 24 horas en 1 dia * 7 dias en una semana / 50 segundos por bloque = 40320.
        // se generan 40320 bloques en una semana.
        endBlock = startBlock + 40320; // Esto significa que la subasta estara funcionando por una semana.
        ipfsHash = "";
        bidIncrement = 100;
    }
}
