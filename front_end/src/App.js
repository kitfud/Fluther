import logo from './jellies_01.jpg';
import './App.css';
import { ConnectWallet } from "@thirdweb-dev/react";

function App() {
  return (

    <div className="App">
        <ConnectWallet
              dropdownPosition={{
                side: "bottom",
                align: "center",
              }}/>
               
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Front end placeholder.
        </p>
      </header>
    </div>
  );
}

export default App;
