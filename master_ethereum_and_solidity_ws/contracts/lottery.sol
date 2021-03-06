//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Lottery {
    // Hay dos tipos de addresses la payable, que pueden recibir eth, y la plana que no pueden.
    address payable[] public players; // Se le pone que son payable addresses ya que al ganador se le tiene que transferir el dinero.
    address public manager;

    constructor() {
        manager = msg.sender;
        players.push(payable(manager)); // adding the manager to the lottery without sending ether
    }

    // Con la funcion recieve asi como esta definida puedo recibir eth
    receive() external payable {
        // Todo el codigo que este por encima de los require consumen gas
        //require(msg.value == 100000000000000000); // como cada ticket sale 0,1eth valido que lo que se esta enviendo es 0,1eth en weis
        // Se puede espesificar un sufijo para poner las denominaciones en Gwei o eth y que sean mas legibles:
        require(msg.value == 0.1 ether, "The ticket cost 0.1eth"); // como cada ticket sale 0,1eth valido que lo que se esta enviendo es 0,1eth en weis
        require(msg.sender != manager, "The manager cant participate"); // Desafio 1

        players.push(payable(msg.sender)); // tengo que convertir el address del sender en payable para poder pagarle (la casteo)
    }

    function getBalance() public view returns (uint256) {
        // Comento el require de solo el manager para el challenge 3 ya que si no no puede finalizar la loteria cualquiera
        //require(msg.sender == manager); // Solo el manager puede consultar el balance.
        return address(this).balance;
    }

    // Para identificar el ganador de la loteria se puede tomar de forma aleatoria un indice del array de jugadores y ese sera el ganador
    // Funcion que devuelve un pseudo random integer
    function random() public view returns (uint256) {
        // La funcion kaccak256 va a computar el hash de lo que se le pase. toma un solo argumento del tipo bytes y devuelve bytes
        // abi.encodePacked hace un pack encoding de los argumentos que le paso. Devuelve una variable del tipo bytes
        // block.difficulty es la dificultad de POW del bloque actual
        // block.timestamp es el unix timestamp de bloque actual
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            ); // Casteo todos los bytes del hash en uint para devolver el numero pseudorandom.
    }

    //Funcion que elija al ganador y le transfiera todos los fondos al mismo.
    function pickWinner() public {
        require(players.length >= 3); // La cantidad de jugadores debe ser de 3 o mas.
        if (players.length < 10) {
            require(
                msg.sender == manager,
                "if players < 10 only manager could pick the winner"
            ); // Solo el manager puede elegir al ganador. si hay menos de 10 jugadores
        }

        uint256 r = random();
        address payable winner;

        uint256 index = r % players.length;
        winner = players[index];

        uint256 managerFee = (getBalance() * 10) / 100; // manager fee is 10%
        uint256 winnerPrize = (getBalance() * 90) / 100; // winner prize is 90%

        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);

        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);

        //Luego de elegir al ganador hay que resetear la loteria para poder realizar otra. Lo hacemos reseteando el array de jugadores.
        players = new address payable[](0); // 0 es el tama??o de nuevo array dinamico. Esto resetea la loteria.
        players.push(payable(manager)); // adding the manager to the lottery without sending ether
    }
}
