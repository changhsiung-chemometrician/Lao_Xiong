"""
analyze_election_poll_beta.py

Python port of analyzeElectionPoll_beta.m

Updates a Beta prior with Binomial poll data to decide whether Candidate A
is the projected winner, i.e. whether the lower bound of the central
Bayesian credible interval for A's true support exceeds 50%.

MATLAB -> Python mapping
    betainv(p, a, b)  ->  scipy.stats.beta.ppf(p, a, b)
    betapdf(x, a, b)  ->  scipy.stats.beta.pdf(x, a, b)

Requires: numpy, scipy, matplotlib
"""

import numpy as np
from scipy.stats import beta
import matplotlib.pyplot as plt


def analyze_election_poll_beta(votes_a, votes_b, conf_level, plot=True):
    """
    Parameters
    ----------
    votes_a    : int   - votes received by Candidate A
    votes_b    : int   - votes received by Candidate B (zero is allowed)
    conf_level : float - e.g. 0.9545 (2-sigma), 0.9973 (3-sigma), 0.95
    plot       : bool  - draw the posterior figure (default True)

    Returns
    -------
    is_winner : bool         - True if A's lower credible bound > 0.5
    req_votes : int or None  - minimum votes A needs out of the same poll size
                               (None if no count up to 100% reaches it)
    req_pct   : float        - req_votes as a percentage (nan if req_votes is None)
    """
    # 1. Prior: uniform, uninformative Beta(1, 1)
    alpha_prior = 1
    beta_prior = 1

    # 2. Conjugate update with Binomial data
    alpha_post = alpha_prior + votes_a
    beta_post = beta_prior + votes_b
    total_votes = votes_a + votes_b

    # 3. Central credible interval via the inverse CDF
    alpha_sig = 1 - conf_level
    lower_bound = beta.ppf(alpha_sig / 2, alpha_post, beta_post)
    upper_bound = beta.ppf(1 - alpha_sig / 2, alpha_post, beta_post)

    # 4. Winner test
    if lower_bound > 0.5:
        is_winner = True
        req_votes = votes_a
        req_pct = req_votes / total_votes * 100
        print(f"Candidate A is projected to win with {conf_level * 100:.2f}% confidence.")
    else:
        is_winner = False

        # 5. Minimum votes needed: scan k = votes_a .. total_votes
        #    (vectorized equivalent of the MATLAB for-loop with break)
        k = np.arange(votes_a, total_votes + 1)
        lb_test = beta.ppf(alpha_sig / 2, alpha_prior + k, beta_prior + (total_votes - k))
        hits = np.nonzero(lb_test > 0.5)[0]

        print(f"Candidate A cannot be projected as the winner at {conf_level * 100:.2f}% confidence.")
        if hits.size > 0:
            req_votes = int(k[hits[0]])
            req_pct = req_votes / total_votes * 100
            print(f"They need at least {req_votes} votes ({req_pct:.2f}%) out of "
                  f"{total_votes} total votes to secure this confidence level.")
        else:
            # Sample too small: even a clean sweep does not clear 50% at this level.
            # (The MATLAB version errors here because reqVotes is never assigned.)
            req_votes = None
            req_pct = float("nan")
            print(f"Even {total_votes}/{total_votes} votes would not clear 50% at this "
                  f"confidence level; the sample is too small.")

    # 6. Visualization
    if plot:
        _plot_posterior(alpha_prior, beta_prior, alpha_post, beta_post,
                        lower_bound, upper_bound, votes_a, votes_b,
                        conf_level, is_winner, req_votes, req_pct)

    return is_winner, req_votes, req_pct


def _plot_posterior(alpha_prior, beta_prior, alpha_post, beta_post,
                    lower_bound, upper_bound, votes_a, votes_b,
                    conf_level, is_winner, req_votes, req_pct):
    total_votes = votes_a + votes_b
    conf_pct = conf_level * 100
    share_a = votes_a / total_votes * 100

    # Same dynamic limits as the MATLAB xlim(...), clipped to [0, 1].
    # The curve is drawn across this whole range (the MATLAB version drew only
    # 0.3-0.7, which cuts off lopsided polls such as 9-1 or 10-0).
    x_lo = max(0.0, min(0.4, lower_bound - 0.05))
    x_hi = min(1.0, max(0.6, upper_bound + 0.05))
    x = np.linspace(x_lo, x_hi, 1000)

    # New figure on every call, like MATLAB figure(...). (Passing a fixed num=
    # would make repeated calls draw on top of the same figure.)
    fig, ax = plt.subplots(facecolor="w", figsize=(8, 5.5))
    try:
        fig.canvas.manager.set_window_title("Election Poll Beta-Binomial Analysis")
    except AttributeError:
        pass  # non-GUI backends (e.g. Agg, inline) have no window title
    ax.grid(True)

    # Current posterior (legend carries the poll counts and Beta parameters)
    ax.plot(x, beta.pdf(x, alpha_post, beta_post), "b-", lw=2,
            label=f"Current: A={votes_a}, B={votes_b} ({share_a:.1f}%)  "
                  f"-> Beta({alpha_post}, {beta_post})")

    # Shaded credible interval (legend carries the bounds)
    x_fill = np.linspace(lower_bound, upper_bound, 200)
    ax.fill_between(x_fill, beta.pdf(x_fill, alpha_post, beta_post), 0,
                    color="b", alpha=0.2, linewidth=0,
                    label=f"{conf_pct:.2f}% CI: [{lower_bound:.3f}, {upper_bound:.3f}]")

    # Hypothetical required posterior (legend carries the needed votes)
    if not is_winner and req_votes is not None:
        a_req = alpha_prior + req_votes
        b_req = beta_prior + (total_votes - req_votes)
        lb_req = beta.ppf((1 - conf_level) / 2, a_req, b_req)
        ax.plot(x, beta.pdf(x, a_req, b_req), "r--", lw=2,
                label=f"Required: A={req_votes}/{total_votes} ({req_pct:.2f}%)  "
                      f"-> lower bound {lb_req:.3f}")

    # 50% threshold
    ax.axvline(0.5, color="k", lw=1.5, label="50% Threshold to Win")

    # Title: the command-window verdict in short form
    if is_winner:
        verdict = f"A projected to WIN at {conf_pct:.2f}% confidence"
    elif req_votes is not None:
        verdict = (f"A NOT projected to win at {conf_pct:.2f}% -- "
                   f"needs >= {req_votes}/{total_votes} votes ({req_pct:.2f}%)")
    else:
        verdict = (f"A NOT projected to win at {conf_pct:.2f}% -- "
                   f"even {total_votes}/{total_votes} is not enough (sample too small)")
    ax.set_title(f"Beta Posterior for Candidate A (n={total_votes})\n{verdict}",
                 fontsize=11)

    ax.set_xlabel("Proportion of True Support (p)")
    ax.set_ylabel("Probability Density")
    ax.set_xlim(x_lo, x_hi)
    ax.legend(loc="best", fontsize=9)
    fig.tight_layout()
    plt.show()


# ----------------------------------------------------------------------------
# Usage examples (the MATLAB "if false" block)
# ----------------------------------------------------------------------------
if __name__ == "__main__":
    examples = [
        # Example 1: close poll, n=1000, 2-sigma
        (510, 490, 0.9545),
        # Example 2: wider margin, n=1000, 3-sigma
        (560, 440, 0.9973),
        # Example 3: small sample (n=100) needs a larger % margin
        (55, 45, 0.95),
        # Example 4: large sample (n=10,000), same ratio as Example 1
        (5100, 4900, 0.95),
        # Q4 Lab17 CIS400
        (85, 15, 0.9545),
        # revisit for JT project, 0923, 2026
        (60, 40, 0.95),
        (59, 41, 0.95),
        (6, 4, 0.95),
        (8, 2, 0.95),
        (9, 1, 0.95),
        (10, 0, 0.95),   # zero votes for B is fine
    ]

    for va, vb, cl in examples:
        print(f"\n--- A={va}, B={vb}, conf={cl} ---")
        is_win, req_v, req_p = analyze_election_poll_beta(va, vb, cl, plot=False)
        print(f"  -> is_winner={is_win}, req_votes={req_v}, req_pct={req_p:.2f}")

# ============================================================================
# For a normal distribution (Empirical Rule, 68-95-99.7):
#   1 sigma -> ~68%   of data within mu +/- 1 sigma
#   2 sigma -> ~95%   of data within mu +/- 2 sigma
#   3 sigma -> ~99.7% of data within mu +/- 3 sigma
# ============================================================================
