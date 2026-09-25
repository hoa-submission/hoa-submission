Anonymous team 在 Lean-Eval 上解出 165 道研究级数学题

我们是 Anonymous team。目前，我们已经在 Lean-Eval 上完成并验证了 165 道题。

Lean-Eval 是一个公开、提交制的 Lean 形式化榜单，核心评测对象是 research-level mathematics。目前主榜有 239 道计分题，另有 8 道内部测试题。

这里不是简单的 tactic 练习。题目包括 Green–Tao 定理，也就是 Ben Green 和陶哲轩证明的“素数中存在任意长等差数列”，以及 Feit–Thompson 奇数阶定理、Brouwer 不动点定理、Abel–Ruffini、Cauchy–Kovalevskaya 和 Hopf–Rinow 等重大结果。

榜单保护原始定理，只把提交者的证明文件放进干净工作区。证明必须通过 comparator 和独立内核重放才计为 solved，因此 165 是在统一、机器可检查的规则下得到的结果。

我们更想分享的是：flow 和 agent loop 可以成为模型能力的放大器。

每道题开始时，我们先让模型把数学思路写成明确的自然语言证明，再进入 Humanize。Worker 随后把这条证明路线映射到准确的 Lean 陈述、Mathlib API 和桥接引理。

Humanize flow 和 RLCR agent loop 会在多轮中固定目标。一个 agent 实现，独立 reviewer 找问题，编译错误、验证失败和 review 意见直接进入下一轮。Stop hook 阻止过早结束。它们不替模型思考，而是提供结构、记忆、真实反馈和反复纠错的机会，从而放大模型已有的推理能力。

IMO 2026 已经展示过同一原理：GPT-5.6 和 Kimi K3 两条路线都完成了 6/6 Lean 验证。现在，Lean-Eval 上的 165 道题把这套方法扩展到了更广泛的研究级数学。

Lean-Eval 榜单：
https://leanprover.github.io/lean-eval-leaderboard/

方法与复现：
https://github.com/anonymous/lean-eval-code

IMO 2026：
https://github.com/anonymous/imo2026
