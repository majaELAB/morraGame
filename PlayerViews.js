import React from "react";

const exports = {};

exports.GetHand = class extends React.Component {
  render() {
    const { parent, playable, hand } = this.props;
    return (
      <div>
        {hand ? "Draw! A new hand" : ""}
        <br />
        {!playable ? "Please wait..." : ""}
        <br />
        {"Please pick a hand"}
        <br />
        <br />
        <button disabled={!playable} onClick={() => parent.playHand(0)}>
          0
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(1)}>
          1
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(2)}>
          2
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(3)}>
          3
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(4)}>
          4
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(5)}>
          5
        </button>
      </div>
    );
  }
};

exports.GetResult = class extends React.Component {
  render() {
    //constants ?
    const { parent, playable, result } = this.props;
    return (
      <div>
        {result ? "It was a draw, result again!" : ""}
        <br />
        {!playable ? "Please Wait..." : ""}
        <br />
        {"Please result the total"}
        <br />
        <br />
        <button disabled={!playable} onClick={() => parent.playResult(0)}>
          0
        </button>
        <button disable={!playable} onClick={() => parent.playResult(1)}>
          1
        </button>
        <button disable={!playable} onClick={() => parent.playResult(2)}>
          2
        </button>
        <button disable={!playable} onClick={() => parent.playResult(3)}>
          3
        </button>
        <button disable={!playable} onClick={() => parent.playResult(4)}>
          4
        </button>
        <button disable={!playable} onClick={() => parent.playResult(5)}>
          5
        </button>
        <button disable={!playable} onClick={() => parent.playResult(6)}>
          6
        </button>
        <button disable={!playable} onClick={() => parent.playResult(7)}>
          7
        </button>
        <button disable={!playable} onClick={() => parent.playResult(8)}>
          8
        </button>
        <button disable={!playable} onClick={() => parent.playResult(9)}>
          9
        </button>
        <button disable={!playable} onClick={() => parent.playResult(10)}>
          10
        </button>
      </div>
    );
  }
};


exports.WaitingForResults = class extends React.Component {
  render() {
    return <div>Waiting for results...</div>;
  }
};

exports.Done = class extends React.Component {
  render() {
    const { outcome } = this.props;
    return (
      <div>
        Thank you for playing. The outcome of this game was:
        <br />
        {outcome || "Unknown"}
      </div>
    );
  }
};

exports.Timeout = class extends React.Component {
  render() {
    return <div>There's been a timeout. (Someone took too long.)</div>;
  }
};

export default exports;
