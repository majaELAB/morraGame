"reach 0.1";

const [isHand, H_ZERO, H_ONE, H_TWO, H_THREE, H_FOUR, H_FIVE] = makeEnum(6);
const [
  isResult,
  R_ZERO,
  R_ONE,
  R_TWO,
  R_THREE,
  R_FOUR,
  R_FIVE,
  R_SIX,
  R_SEVEN,
  R_EIGHT,
  R_NINE,
  R_TEN,
] = makeEnum(11);
const [isOutcome, Maja_WINS, DRAW, Danilo_WINS] = makeEnum(3);
const winner = (handMaja, handDanilo, resultMaja, resultDanilo) => {
  if (resultMaja == resultDanilo) {
    return DRAW;
  }
  else if (handMaja + handDanilo == resultMaja) {
    return Maja_WINS;
  } else if (handMaja + handDanilo == resultDanilo) {
    return Danilo_WINS;
  } else {
    return DRAW;
  }
};

assert(winner(H_ZERO, H_ZERO, R_ZERO, R_ZERO) == DRAW);
assert(winner(H_ZERO, H_ZERO, R_ONE, R_ZERO) == Danilo_WINS);
assert(winner(H_ZERO, H_ZERO, R_ZERO, R_ONE) == Maja_WINS);

forall(UInt, (handMaja) =>
  forall(UInt, (handDanilo) =>
    forall(UInt, (resultMaja) =>
      forall(UInt, (resultDanilo) =>
        assert(isOutcome(winner(handMaja, handDanilo, resultMaja, resultDanilo)))
      )
    )
  )
);

forall(UInt, (handMaja) =>
  forall(UInt, (handDanilo) =>
    forall(UInt, (result) =>
      assert(winner(handMaja, handDanilo, result, result) == DRAW)
    )
  )
);

const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  getResult: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
  const Maja = Participant("Maja", {
    ...Player,
    wager: UInt,
    deadline: UInt,
  });
  const Danilo = Participant("Danilo", {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });

  init();

  const informTimeout = () => {
    each([Maja, Danilo], () => {
      interact.informTimeout();
    });
  };

  Maja.only(() => {
    const amount = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
  });

  Maja.publish(amount, deadline).pay(amount);
  commit();

  Danilo.only(() => {
    interact.acceptWager(amount);
  });
  Danilo.pay(amount).timeout(relativeTime(deadline), () =>
    closeTo(Maja, informTimeout)
  );

  var outcome = DRAW;
  invariant(balance() == 2 * amount && isOutcome(outcome));
  while (outcome == DRAW) {
    commit();

    Maja.only(() => {
      const _handMaja = interact.getHand();
      const [_commitHandMaja, _saltHandMaja] = makeCommitment(
        interact,
        _handMaja
      );
      const commitHandMaja = declassify(_commitHandMaja);
      
      const _resultMaja = interact.getResult();
      const [_commitResultMaja, _saltResultMaja] = makeCommitment(
        interact,
        _resultMaja
      );
      const commitResultMaja = declassify(_commitResultMaja);
    });

    Maja.publish(commitHandMaja, commitResultMaja).timeout(
      relativeTime(deadline),
      () => {
        closeTo(Danilo, informTimeout);
      }
    );
    commit();

    unknowable(
      Danilo,
      Maja(_handMaja, _saltHandMaja, _resultMaja, _saltResultMaja)
    );

    Danilo.only(() => {
      const handDanilo = declassify(interact.getHand());
      const resultDanilo = declassify(interact.getResult());
    });
    Danilo.publish(handDanilo, resultDanilo).timeout(relativeTime(deadline), () =>
      closeTo(Maja, informTimeout)
    );
    commit();

    Maja.only(() => {
      const saltHandMaja = declassify(_saltHandMaja);
      const handMaja = declassify(_handMaja);

      const saltResultMaja = declassify(_saltResultMaja);
      const resultMaja = declassify(_resultMaja);
    });
    Maja.publish(
      handMaja,
      saltHandMaja,
      resultMaja,
      saltResultMaja
    ).timeout(relativeTime(deadline), () => {
      closeTo(Danilo, informTimeout);
    });

    checkCommitment(commitHandMaja, saltHandMaja, handMaja);
    checkCommitment(commitResultMaja, saltResultMaja, resultMaja);
    outcome = winner(handMaja, handDanilo, resultMaja, resultDanilo);
    continue;
  } 

  assert(outcome == Maja_WINS || outcome == Danilo_WINS);

  transfer(2 * amount).to(outcome == Maja_WINS ? Maja : Danilo);
  commit();

  each([Maja, Danilo], () => {
    interact.seeOutcome(outcome);
  });
});
