"""
election_poll_gui.py

Simple GUI front end for analyze_election_poll_beta.py

    Inputs : votesA, votesB, confLevel
    Buttons: [Show Results]  -> runs the analysis, prints the command-window
                                text into the GUI log (newest on top, older
                                runs pushed down), and opens a new figure
             [Close All Figures] -> plt.close('all')

Run:
    python election_poll_gui.py

Requires analyze_election_poll_beta.py in the same folder, plus
numpy, scipy, matplotlib (tkinter ships with standard Python).
"""

import io
import contextlib
import tkinter as tk
from tkinter import ttk, messagebox

import matplotlib
matplotlib.use("TkAgg")           # Tk backend so figures share the GUI event loop
import matplotlib.pyplot as plt

from analyze_election_poll_beta import analyze_election_poll_beta

plt.ion()                         # non-blocking figures: GUI stays responsive

CONF_PRESETS = ["0.90", "0.95", "0.9545", "0.99", "0.9973"]


class ElectionPollApp:
    def __init__(self, root):
        self.root = root
        root.title("Election Poll Beta-Binomial Analysis")
        root.resizable(False, False)
        root.protocol("WM_DELETE_WINDOW", self.on_quit)

        style = ttk.Style(root)
        style.configure("TLabel", font=("Helvetica", 12))
        style.configure("TButton", font=("Helvetica", 12, "bold"), padding=6)

        frm = ttk.Frame(root, padding=14)
        frm.grid(sticky="nsew")

        # ---- inputs (own sub-frame so the wide output box doesn't stretch them)
        self.var_a = tk.StringVar(value="59")
        self.var_b = tk.StringVar(value="41")
        self.var_c = tk.StringVar(value="0.95")

        inp = ttk.Frame(frm)
        inp.grid(row=0, column=0, columnspan=3, sticky="w")
        ent = dict(width=12, font=("Helvetica", 12))

        ttk.Label(inp, text="votesA").grid(row=0, column=0, sticky="w", pady=3, padx=(0, 10))
        ttk.Entry(inp, textvariable=self.var_a, **ent).grid(row=0, column=1, sticky="w", pady=3)

        ttk.Label(inp, text="votesB").grid(row=1, column=0, sticky="w", pady=3, padx=(0, 10))
        ttk.Entry(inp, textvariable=self.var_b, **ent).grid(row=1, column=1, sticky="w", pady=3)

        ttk.Label(inp, text="confLevel").grid(row=2, column=0, sticky="w", pady=3, padx=(0, 10))
        ttk.Combobox(inp, textvariable=self.var_c, values=CONF_PRESETS,
                     **ent).grid(row=2, column=1, sticky="w", pady=3)
        ttk.Label(inp, text="(0.9545 = 2σ, 0.9973 = 3σ)",
                  foreground="gray").grid(row=2, column=2, sticky="w", padx=8)

        # ---- buttons ------------------------------------------------------
        btns = ttk.Frame(frm)
        btns.grid(row=1, column=0, columnspan=3, sticky="w", pady=(10, 8))
        ttk.Button(btns, text="Show Results",
                   command=self.show_results).grid(row=0, column=0, padx=(0, 8))
        ttk.Button(btns, text="Close All Figures",
                   command=self.close_figures).grid(row=0, column=1)

        # ---- output (the "command window") --------------------------------
        self.out = tk.Text(frm, width=78, height=12, wrap="word",
                           font=("Courier", 11), state="disabled")
        self.out.grid(row=2, column=0, columnspan=3, sticky="nsew")
        sb = ttk.Scrollbar(frm, orient="vertical", command=self.out.yview)
        sb.grid(row=2, column=3, sticky="ns")
        self.out.configure(yscrollcommand=sb.set)

        root.bind("<Return>", lambda e: self.show_results())

    # ----------------------------------------------------------------------
    def _parse_inputs(self):
        try:
            a = int(self.var_a.get().strip())
            b = int(self.var_b.get().strip())
        except ValueError:
            raise ValueError("votesA and votesB must be whole numbers.")
        try:
            c = float(self.var_c.get().strip())
        except ValueError:
            raise ValueError("confLevel must be a number, e.g. 0.95.")
        if a < 0 or b < 0:
            raise ValueError("Votes cannot be negative.")
        if a + b == 0:
            raise ValueError("Total votes must be greater than zero.")
        if not 0 < c < 1:
            raise ValueError("confLevel must be between 0 and 1 (e.g. 0.95).")
        return a, b, c

    def _append(self, text):
        # Newest entry goes on TOP (same as the MATLAB GUI); older runs are
        # pushed down. text ends with a blank line, which separates the runs.
        self.out.configure(state="normal")
        self.out.insert("1.0", text)
        self.out.see("1.0")
        self.out.yview_moveto(0)
        self.out.configure(state="disabled")

    def show_results(self):
        try:
            a, b, c = self._parse_inputs()
        except ValueError as err:
            messagebox.showerror("Invalid input", str(err), parent=self.root)
            return

        # Capture the function's printed (command-window) messages
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            is_win, req_v, req_p = analyze_election_poll_beta(a, b, c, plot=True)

        req_v_txt = "None" if req_v is None else str(req_v)
        self._append(
            f">> analyze_election_poll_beta({a}, {b}, {c})\n"
            f"{buf.getvalue()}"
            f"   is_winner = {is_win},  req_votes = {req_v_txt},  req_pct = {req_p:.2f}\n\n"
        )

    def close_figures(self):
        plt.close("all")

    def on_quit(self):
        plt.close("all")
        self.root.destroy()


def main():
    root = tk.Tk()
    ElectionPollApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
