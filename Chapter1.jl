### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ea410cb2-05f9-41a2-b06e-7ecada7ade93
begin
	using Distributions
	using Plots
	using PlutoUI
	using Random
end

# ╔═╡ c57a4eb1-f711-4bfb-a0c9-0973b7011671
md"# Gaussian random variables and Gaussian processes"

# ╔═╡ da5c325b-0d47-4f63-8678-fcd83ea7f98b
md"""
## Julia utilities
"""

# ╔═╡ 4b5cdd8f-b26a-42a9-be50-37701adf7226
Random.seed!(2025)

# ╔═╡ 5ea137ec-09d2-42d6-8c05-4d09b48b7741
md"""
## Gaussian random variables

 - [Random variables](https://en.wikipedia.org/wiki/Random_variable) are defined on a [probability space](https://en.wikipedia.org/wiki/Probability_space) $(\Omega, \mathscr{F}, P)$
   - [Sample space](https://en.wikipedia.org/wiki/Sample_space) $\Omega$: the set of all outcomes
   - [Event space](https://en.wikipedia.org/wiki/Event_(probability_theory)) $\mathscr{F}$: a set of events, each of which is a subset of outcomes in the sample space
   - [Probability function](https://en.wikipedia.org/wiki/Probability_measure) $P$: function from $\mathscr{F}\to[0,1]$
 - For $p\ge 1\in\mathbb{R}$, [$L^p(\Omega,\mathscr{F},P)$](https://en.wikipedia.org/wiki/Lp_space) denotes the space of all real random variables $X$ such that $|X|^p$ is integrable (expecteed value exists and is finite)
   - The $L^p$ space is equipped with the appropriate norm $||X||_p=\mathbb{E}[|X|^p]^{\frac1p}$
 - Two random variables that are [almost surely](https://en.wikipedia.org/wiki/Almost_surely) equal (differ with probability zero; analogous to equal almost everywhere in measure theory) are treated as identical
 - A real random variable $X$ is said to be a [standard Gaussian (normal) variable](https://en.wikipedia.org/wiki/Normal_distribution) if its law (probability distribution) has [density](https://en.wikipedia.org/wiki/Probability_density_function) $p_X(x)=\frac{1}{\sqrt{2\pi}}\exp(-\frac{x^2}{2})$
 - The complex [Laplace transform](https://en.wikipedia.org/wiki/Laplace_transform) of $X$ is then given by $\mathbb{E}[\mathrm{e}^{zX}]=\mathrm{e}^{\frac{z^2}{2}}, \forall z\in\mathbb{C}$
   - when $z=\lambda\in\mathbb{R}$, we have $\mathbb{E}[\mathrm{e}^{\lambda X}]=\frac{1}{\sqrt{2\pi}}\int_{\mathbb{R}}{\mathrm{e}^{\lambda x}\mathrm{e}^{-\frac{x^2}{2}}}\,\mathrm{d}x=\mathrm{e}^{\frac{\lambda^2}{2}}\frac{1}{\sqrt{2\pi}}\int_{\mathbb{R}}{\mathrm{e}^{-\frac{(x-\lambda)^2}{2}}}\,\mathrm{d}x=\mathrm{e}^{\frac{\lambda^2}{2}}$
   - this calculation ensures that $\mathbb{E}[\mathrm{e}^{z X}]$ is well-defined $\forall z\in\mathbb{C}$ and defines a [holomorphic function](https://en.wikipedia.org/wiki/Holomorphic_function) on $\mathbb{C}$
   - by [analytic continuation](https://en.wikipedia.org/wiki/Analytic_continuation), $\mathbb{E}[\mathrm{e}^{z X}]=\mathrm{e}^{\frac{z^2}{2}}$ must also be true $\forall z\in\mathbb{C}$
      - taking $z=\mathrm{i}\xi,\xi\in\mathbb{R}$, we get the [characteristic function](https://en.wikipedia.org/wiki/Characteristic_function_(probability_theory)) of $X$: $\mathbb{E}[\mathrm{e}^{\mathrm{i}\xi X}]=\mathrm{e}^{-\frac{\xi^2}{2}}$
      - applying [Taylor's theorem](https://en.wikipedia.org/wiki/Taylor%27s_theorem), we get $\mathbb{E}[\mathrm{e}^{\mathrm{i}\xi X}]=1+\mathrm{i}\xi\mathbb{E}[X]+\cdots+\frac{(\mathrm{i}\xi)^n}{n!}\mathbb{E}[X^n]+O(|\xi|^{n+1})$
      - as $\xi\to0$, we get $\mathbb{E}[X]=0$ and $\mathbb{E}[X^2]=1$
      - more generally, for $n\ge 0\in\mathbb{Z}$, $\mathbb{E}[X^{2n}]=\frac{(2n)!}{2^n n!}$ and $\mathbb{E}[X^{2n+1}]=0$
 - For $\sigma>0$ and $m\in\mathbb{R}$, we say that a real random variable $Y$ is Gaussian with $\mathscr{N}(m,\sigma^2)$ distribution if 
   -  $Y$ satisfies any of these equivalent properties:
      -  $Y=\sigma X+m$, where $X\sim\mathscr{N}(0,1)$
      - the law of $Y$ has density $p_Y(y)=\frac{1}{\sqrt{2\pi}}\exp(-\frac{(y-m)^2}{2\sigma^2})$
      - the characteristic function of $Y$ is $\mathbb{E}[\mathrm{e}^{\mathrm{i}\xi Y}]=\exp(\mathrm{i}m\xi-\frac{\sigma^2}{2}\xi^2)$
   -  [$\mathbb{E}[Y]=m$](https://en.wikipedia.org/wiki/Expected_value) and [$\mathrm{var}(Y)=\sigma^2$](https://en.wikipedia.org/wiki/Variance) follow consequently
   -  $Y$ is Gaussian with $\mathscr{N}(m,0)$ if $Y=m$ a.s.
 - **Sums of independent Gaussian variables.** Suppose independent $Y\sim\mathscr{N}(m,\sigma^2),Y'\sim\mathscr{N}(m',\sigma'^{2})$. Then, $Y+Y'\sim\mathscr{N}(m+m',\sigma^2+\sigma'^2)$ (follows from characteristic function).
 - **Proposition 1.1.** Let $(X_n)_{n\ge1}$ be a sequence of real random variables such that $X_n\sim\mathscr{N}(m_n,\sigma^2_n)$. Suppose $X_n$ [converges](https://en.wikipedia.org/wiki/Convergence_of_random_variables) in $L^2$ to $X$ ($\lim_{n\to\infty}[\mathbb{E}[|X_n|^2]]=\mathbb{E}[|X|^2]$). Then:
   -  $X\sim\mathscr{N}(m,\sigma^2)$, where $m=\lim_{n\to\infty}[m_n]$ and $\sigma=\lim_{n\to\infty}[\sigma_n]$
      - convergence in $L^2$ implies that $m_n=\mathbb{E}[X_n]$ converges to $\mathbb{E}[X]$ and $\sigma_n^2=\mathrm{var}(X_n)$ converges to $\mathrm{var}(X)$ as $n\to\infty$
      - then, setting $m=\mathbb{E}[X]$ and $\sigma^2=\mathrm{var}(X)$, we have $\forall\xi\in\mathbb{R}$, $\mathbb{E}[\mathrm{e}^{\mathrm{i}\xi X}]=\lim_{n\to\infty}[\mathbb{E}[\mathrm{e}^{\mathrm{i}\xi X_n}]]=\lim_{n\to\infty}[\exp(\mathrm{i}m_n-\frac{\sigma_n^2}{2}\xi^2)]=\exp(\mathrm{i}m\xi-\frac{\sigma^2}{2}\xi^2)$
      - thus, $X\sim\mathscr{N}(m,\sigma^2)$
   - the convergence also holds in all $L^p$ spaces, $1\le p<\infty$
      - since $X_n\sim\sigma_n N+m_n$, where $N\sim\mathscr{N}(0,1)$, and since $\{m_n\}$ and $\{\sigma_n\}$ are bounded, we get $\forall q\ge 1:\sup_n[\mathbb{E}[|X_n|^q]]<\infty$
      - it follows that $\sup_n[\mathbb{E}[|X_n-X|^q]]<\infty$
      - for $p\ge 1$, $Y_n=|X_n-X|^p$ converges in probability to $0$ and is [uniformly integrable](https://en.wikipedia.org/wiki/Uniform_integrability) because it is bounded in $L^2$ (with $q=2p$)
      - it follows that $Y_n\to0$ in $L^1$ (and consequently in all other $L^p$ spaces)
   - convergence in $L^2$ can be weakened to convergence in probability ($\lim_{n\to\infty}[|X_n-X|<\varepsilon]=0,\forall\varepsilon>0$)
"""

# ╔═╡ 2ab954fb-8924-4a53-b4ae-e201c28802ca
sums_of_independent_gaussian_variables(μ₁, σ₁, μ₂, σ₂, n=1000) = begin
	x₁ = rand(Normal(μ₁, σ₁), n)
	x₂ = rand(Normal(μ₂, σ₂), n)
	sum_samples = rand(Normal(μ₁+μ₂, √(σ₁^2+σ₂^2)), n)
	l = @layout [a b; c]
	p1 = histogram(x₁, bins=50, label="x₁~N($(round(μ₁, digits=2)),$(round(σ₁^2, digits=2)))", color=1, normalize=true, alpha=0.6)
	p2 = histogram(x₂, bins=50, label="x₂~N($(round(μ₂, digits=2)),$(round(σ₂^2, digits=2)))", color=2, normalize=true, alpha=0.6)
	p3 = histogram(x₁+x₂, bins=50, label="x₁+x₂", color=3, alpha=0.3, normalize=true)
	plot!(p3, histogram!(sum_samples, bins=50, label="x~N($(round(μ₁+μ₂, digits=2)),$(round(σ₁^2+σ₂^2, digits=2)))", color=4, alpha=0.3, normalize=true))
	plot(p1, p2, p3, layout=l, size=(800, 500), plot_title="Sums of independent Gaussian variables")
end

# ╔═╡ 98425061-9b51-4b46-a31f-93a224c2ae1b
md"""

μ₁: $(@bind μ₁ Slider(-10:0.01:10, default=0, show_value=true))

σ₁: $(@bind σ₁ Slider(0:0.01:10, default=1, show_value=true))

μ₂: $(@bind μ₂ Slider(-10:0.01:10, default=0, show_value=true))

σ₂: $(@bind σ₂ Slider(0:0.01:10, default=1, show_value=true))

n: $(@bind n Slider((10).^(1:8), default=1000, show_value=true))

"""

# ╔═╡ ec0ea3e4-127f-4681-b6f8-f7f054309ec1
sums_of_independent_gaussian_variables(μ₁, σ₁, μ₂, σ₂, n)

# ╔═╡ 26dc1d65-8bee-4518-8930-07ac5f965503
md"""
## Gaussian vectors
 - Notation
   - let $E$ be a $d$-dimensional [Euclidean space](https://en.wikipedia.org/wiki/Euclidean_space) (isomorphic to $\mathbb{R}^d$ and typically equipped with the usual inner product)
   - [inner products](https://en.wikipedia.org/wiki/Inner_product_space) are denoted $\langle u,v\rangle$
   - a random variable $X$ with values in $E$ is called a Gaussian vector if, for every $u\in E$, $\langle u, X\rangle$ is a real Gaussian variable
      - e.g. $E=\mathbb{R}^d$ and $X=[X_1,\dots,X_d]$ with each $X_i$ an [independent](https://en.wikipedia.org/wiki/Independence_(probability_theory)) Gaussian variable
   - let $X$ be a Gaussian vector with values in $E$; then there exist $m_X\in E$ and a nonnegative [qudratic form](https://en.wikipedia.org/wiki/Quadratic_form) $q_X$ on $E$ such that for every $u\in E$, $\mathbb{E}[\langle u, X\rangle]=\langle u, m_X\rangle$ and $\mathrm{var}(\langle u, X\rangle)=q_X(u)$
   - let $(e_1, \dots, e_d)$ be an [orthonormal bases](https://en.wikipedia.org/wiki/Orthonormal_basis) on $E$, and write $X=\sum_{i=1}^d{\langle e_j, X\rangle e_j}$; the previous formulas then hold with
      -  $m_X=\sum_{j=1}^d{\mathbb{E}[X_j]e_j}=\mathbb{E}[X]$
      - if $u=\sum_{j=1}^d{u_je_j}$, then $q_x(u)=\sum_{j,k=1}^{d}{u_ju_k\mathrm{cov}(X_j,X_k)}$
   - since $\langle u,X\rangle\sim\mathscr{N}(\langle u,m_X\rangle, q_X(u))$, we get the characteristic function of the random vector $X$, $\mathbb{E}[\exp(\mathrm{i}\langle u,m_X\rangle)]=\exp(\mathrm{i}\langle u,m_X\rangle-\frac12q_X(u))$
 - **Proposition 1.2.** Under the preceding assumptions, the random variables $X_1,\dots,X_d$ are independent if and only if the [covariance matrix](https://en.wikipedia.org/wiki/Covariance_matrix) $(\mathrm{cov}(X_j,X_k))_{1\le j,k\le d}$ is diagonal or equivalently if and only if $q_X$ is of [diagonal form](https://en.wikipedia.org/wiki/Diagonal_form) in the basis $(e_1,\dots,e_d)$
   - if the random variables $X_1,\dots,X_d$ are independent, the covariance matrix $(\mathrm{cov}(X_J,X_k))_{1\le j,k\le d}$ is diagonal
   - conversely, if the covariance matrix is diagonal, we have for every $u\in\sum_{j=1}^d{u_je_j}\in E$, $q_X(u)=\sum_{j=1}^{d}\lambda_iu_j^2$, where $\lambda_j=\mathrm{var}(X_j)$
   - consequently, using the characteristic function equation, we get $\mathbb{E}[\exp(\mathrm{i}\sum_{j=1}^{d}u_jX_j)]=\prod_{j=1}^{d}\exp(\mathrm{i}u_j\mathbb{E}[X_j]-\frac{1}{2}\lambda_j u_j^2)=\prod_{j=1}^{d}\mathbb{E}[\exp(\mathrm{i}u_jX_j)]$, implying that $X_1,\dots,X_d$ are independent
   - with the quadratic form $q_X$, we associate the unique symmetric [endomorphism](https://en.wikipedia.org/wiki/Endomorphism) $\gamma_X$ of $E$ such that $q_X(u)=\langle y,\gamma_X(u)\rangle$ with $\gamma_X$ having all nonnegative [eigenvalues](https://en.wikipedia.org/wiki/Eigenvalues_and_eigenvectors)
 - **Theorem 1.3.** (i) Let $\gamma$ be a nonnegative symmetric endomorphism of $E$. Then there exists a Gaussian vector $X$ such that $\gamma_X=\gamma$. 
   - let $(e_1,\dots,e_d)$ be an orthonormal basis of $E$ in which $\gamma$ is diagonal, $\gamma(e_j)=\lambda_je_j$ for $1\le j\le d$, and let $Y_1,\dots,Y_d$ be independent centered Gaussian variables with $\mathrm{var}(Y_j)=\lambda_j,1\le j\le d$
   - we set $X=\sum_{j=1}^{d}Y_je_j$
   - then if $u=\sum_{j=1}^{d}Y_je_j$, $q_X(u)=\mathbb{E}[(\sum_{j=1}^{d}u_j Y_j)^2]=\sum_{j=1}^{d}\lambda_ju_j^2=\langle y,\gamma(u)\rangle$
 - **Theorem 1.3.** (ii) Let $X$ be a centered Gaussian vector and $(e_1,\dots,e_d)$ be a basis of $E$ in which $\gamma_X$ is diagonal, $\gamma_Xe_j=\lambda_je_j$ for every $1\le j\le d$, where $\lambda_1\ge \lambda_2\ge\cdots\ge\lambda_r>0=\lambda_{r+1}=\cdots=\lambda_d$ so that $r$ is the rank of $\gamma_X$. Then, $X=\sum_{j=1}^{r}Y_j e_j$, where $Y_j$ for $1\le j\le r$ are independent centered Gaussian variables and the variance of $Y_j$ is $\lambda_j$. Consequently, if $P_X$ denotes the distribution of $X$, the [topological support](https://en.wikipedia.org/wiki/Support_(measure_theory)) of $P_X$ is the vector space [spanned](https://en.wikipedia.org/wiki/Linear_span) by $e_1,\dots,e_4$. Furthermore, $P_X$ is [absolutely continuous](https://en.wikipedia.org/wiki/Absolute_continuity) with respect to [Lebesgue measure](https://en.wikipedia.org/wiki/Lebesgue_measure) on $E$ if and only if $r=d$, and in that case the density of $X$ is $p_X(x)=\frac{1}{(2\pi)^{\frac{d}{2}}\sqrt{\mathrm{det}(\gamma_X)}}\exp(-\frac12\langle x,\gamma_X^{-1}(x)\rangle)$
   - let $Y_1,\dots,Y_d$ be the coordinates of $X$ in the basis $(e_1,\dots,e_2)$
   - the matrix of $\gamma_X$ in this basis is the covariance matrix of $Y_1,\dots,Y_d$ (which is diagonal, implying that $Y_1,\dots,Y_d$ are independent)
   - for $j\in\{r+1,\dots,d\}$, we have $\mathbb{E}[Y_j^2]=0$ and thus $Y_j=0$ a.s.
   - then, since $X=\sum_{j=1}^r Y_je_j$ a.s., it is clear that $\mathrm{supp}(P_X)$ is contained in the subspace spanned by $e_1,\dots,e_r$
   - conversely, if $O$ is a rectangle of the form $O=\{u=\sum_{j=1}^{r}\alpha_je_j:a_j<\alpha_j<b_j,\forall 1\le j\le r\}$, we have $P[X\in O]=\prod_{j=1}^{r} P[a_j< Y_j<b_j]>0$
   - if $r<d$, since the vector space spanned by $e_1,\dots,e_r$ has zero Lebesgue measure, the distribution of $X$ is [singular](https://en.wikipedia.org/wiki/Singular_measure) with respect to Lebesgue measure on $E$
   - suppose $r=d$ and write $Y$ for the random vector in $\mathbb{R}^d$ defined by $Y=(Y_1,\dots,Y_d)$
   - note that there exists [bijection](https://en.wikipedia.org/wiki/Bijection) $\phi:Y\to X$ defined by $\phi(y_1,\dots,y_d)=\sum_{j=1}^d y_je_j$
   - then, we have $\mathbb{E}[g(X)]=\mathbb{E}[g(\phi(Y))]$
   - since Lebesgue measure on $E$ is by definition the image of Lebesgue measure on $\mathbb{R}^d$ under $\phi$, we have $\mathbb{E}[g(X)]=\frac{1}{(2\pi)^{\frac{d}{2}}}\int_{\mathbb{R}^d}g(\phi(y))\exp(-\frac{1}{2}\sum_{j=1}^{d}\frac{y_j^2}{\lambda_j})\,\mathrm{d}y_1,\dots,\mathrm{d}y_d$
   - since $Y_1,\dots,Y_d$ are independent Gaussian variables, we have $\mathbb{E}[g(X)]=\frac{1}{(2\pi)^{\frac{d}{2}}\sqrt{\mathrm{det}(\gamma_X)}}\int_{\mathbb{R}^d}g(\phi(y))\exp(-\frac{1}{2}\langle\phi(y),\gamma_X^{-1}(\phi(y))\rangle)\,\mathrm{d}y_1,\dots,\mathrm{d}y_d$
   - since $\langle\phi(y),\gamma_X^{-1}(\phi(y))\rangle=\langle\sum_{j=1}^{d}y_je_j,\sum_{j=1}^{d}\frac{y_j}{\lambda_j}e_j\rangle=\sum_{j=1}^{d}\frac{y_j^2}{\lambda_j}$, we have $\mathbb{E}[g(X)]=\frac{1}{(2\pi)^{\frac{d}{2}}\sqrt{\mathrm{det}(\gamma_X)}}\int_{E}g(x)\exp(-\frac{1}{2}\langle x,\gamma_X^{-1}(x)\rangle)\,\mathrm{d}x$
"""

# ╔═╡ 260fc62b-b068-4901-828b-e53e964a0830
# add some code here

# ╔═╡ 76248865-3759-46b1-80b6-7a7c85362e53
md"""
## Gaussian processes and Gaussian spaces
 - **Definition 1.4.** A centered Gaussian [space](https://en.wikipedia.org/wiki/Space_(mathematics)) is a [closed](https://en.wikipedia.org/wiki/Closed_set) linear subspace of $L^2(\Omega,\mathscr{F},P)$ which contains only centered Gaussian variables (e.g. if $X=(X_1,\dots,X_d)$ is a centered Gaussian vector in $\mathbb{R}^d$, then the vector space spanned by $\{X_1,\dots,X_d\}$ is a Gaussian space)
 - **Definition 1.5.** Let $(E,\mathscr{E})$ be a measurable space and $T$ be an arbitrary [index set](https://en.wikipedia.org/wiki/Index_set) (usually some interval of $\mathbb{R}_+$). A [random process](https://en.wikipedia.org/wiki/Stochastic_process), indexed by $T$, with values in $E$ is a collection $(X_t)_{t\in T}$ of random variables with values in $E$. If the measurable space $(E,\mathscr{E})$ is not specified, we implicitly assume that $E=\mathbb{R}$ and $\mathscr{E}=\mathscr{B}(\mathbb{R})$, the [Borel](https://en.wikipedia.org/wiki/Borel_set) [$\sigma$-field](https://en.wikipedia.org/wiki/Σ-algebra) on $\mathbb{R}$
 - **Definition 1.6.** A real-valued random process $(X_t)_{t\in T}$ is called a centered Gaussian process if any finite [linear combination](https://en.wikipedia.org/wiki/Linear_combination) of the variables $X_t,t\in T$ is centered Gaussian
 - **Proposition 1.7.** If $(X_t)_{t\in T}$ is a Gaussian process, the closed linear subspace of $L^2$ spanned by the variables $X_t, t\in T$ is a Gaussian space generated by the process $X$
   - by proposition 1.1, the $L^2$ limit of a centered Gaussian is still a centered Gaussian
 - **Definition 1.8.** Let $H$ be a collection of random variables defined on $(\Omega, \mathscr{F}, P)$. The $\sigma$-field generated by $H$, denoted by $\sigma(H)$, is the smallest $\sigma$-field on $\Omega$ such that all variables $\xi\in H$ are measurable for this $\sigma$-field. If $\mathscr{C}$ is a collection of subsets of $\Omega$, we also write $\sigma(\mathscr{C})$ for the smallest $\sigma$-field on $\Omega$ that contains all elements of $\mathscr{C}$
 - **Theorem 1.9.** Let $H$ be a centered Gaussian space and let $(H_i)_{i\in I}$ be a collection of linear subspaces of $H$. Then the subspaces $H_i,i\in I$ are pairwise [orthogonal](https://en.wikipedia.org/wiki/Orthogonal_complement) in $L^2$ if and only if the $\sigma$-fields $\sigma(H_i),i\in I$ are independent
   - it is crucial that vector spaces $H_i$ are subspaces of a common Gaussian space $H$ (see book for pathological example)
   - suppose the $\sigma$-fields $\sigma(H_i)$ are independent; then, if $i\ne j$, for $X\in H_i,Y\in H_j$, $\mathbb{E}[XY]=\mathbb{E}[X]\mathbb{E}[Y]=0$ so the linear spaces $H_i$ are pairwise orthogonal
   - conversely, suppose that the linear spaces $H_i$ are pairwise orthogonal; from the definition of independence of an infinite collection of $\sigma$-fields, it is enough to prove that if $i_1,\dots,i_p\in I$ are distinct, the $\sigma$-fields $\sigma(H_{i_1}),\dots,\sigma(H_{i_p})$ are independent
   - I have no idea what happens after this
 - **Corollary 1.10.** Let $H$ be a centered Gaussian space and let $K$ be a closed linear subspace of $H$. Let $p_K$ denote the orthogonal [projection](https://en.wikipedia.org/wiki/Projection_(linear_algebra)) onto $K$ in the [Hilbert space](https://en.wikipedia.org/wiki/Hilbert_space) $L^2$ and let $X\in H$. (i) We have $\mathbb{E}[X\,|\,\sigma(K)]=p_K(X)$. 
   - let $Y=X-p_K(x)$
   - then, $Y$ is orthogonal to $K$ and by theorem 1.9, $Y$ is independent of $\sigma(K)$
   - then, $\mathbb{E}[X\,|\,\sigma(K)]=\mathbb{E}[p_K(X)\,|\,\sigma(K)]+\mathbb{E}[Y\,|\,\sigma(K)]=p_K(X)+\mathbb{E}[Y]=p_K(x)$
   - this claim also gives the principle of [linear regression](https://en.wikipedia.org/wiki/Linear_regression): for instance, if $(X_1,X_2,X_3)$ is a centered Gaussian vector in $\mathbb{R}^3$, the best approximation in $L^2$ of $X_3$ as a not necessarily linear function of $X_1$ and $X_2$ can be written $\lambda_1 X_1+\lambda_2 X_2$, where $\lambda_1$ and $\lambda_2$ are computed by saying $X_3-(\lambda_1 X_1+\lambda_2 X_2)$ is orthogonal to the vector space spanned by $X_1$ and $X_2$
 - **Corollary 1.10.** (ii) Let $\sigma^2=\mathbb{E}[(X-p_K(X))^2]$. Then for every Borel subset $A\subset\mathbb{R}$, the random variable $P[X\in A\,|\,\sigma(K)]$ is given by $P[X\in A\,|\,\sigma(K)](\omega)=Q(\omega, A)$, where $Q(\omega,\cdot)$ denotes the $\mathscr{N}(p_K(X)(\omega),\sigma^2)$ distribution: $Q(\omega, A)=\frac{1}{\sigma\sqrt{2\pi}}\int_A{}\,\mathrm{d}y\,\exp(-\frac{(y-p_K(X)(\omega))^2}{2\sigma^2})$
   - let $f$ be a nonnegative [measurable function](https://en.wikipedia.org/wiki/Measurable_function) on $\mathbb{R}_+$
   - by definition we have $\mathbb{E}[f(X)\,|\,\sigma(K)]=\mathbb{E}[f(p_K(X)+Y)\,|\,\sigma(K)]$
   - let $P_Y$ be the law of $Y$, which is $\mathscr{N}(0,\sigma^2)$
   - it is a general fact (from which the proof follows immediately) that if $Z$ is a $\mathscr{G}$-measurable random variable and if $Y$ is independent of $\mathscr{G}$, then for every nonnegative measurable function $g$, $\mathbb{E}[g(Y,Z)\,|\,\mathscr{G}]=\int g(y,Z)P_Y(\mathrm{d}y)$
   - this can also be interpreted as by saying that the [conditional distribution](https://en.wikipedia.org/wiki/Conditional_probability_distribution) of $X$ knowing $\sigma(K)$ is $\mathscr{N}(p_K(X),\sigma^2)$
 - **Theorem 1.11.** Let $\Gamma$ be a [symmetric function](https://en.wikipedia.org/wiki/Symmetric_function) of positive type on $T\times T$, There exists, on an approximate probability space $(\Omega,\mathscr{F},P)$, a centered Gaussian process whose covariance function is $\Gamma:T\times T\to\mathbb{R}$ defined by $\Gamma(s,t)=\mathrm{cov}(X_s,X_t)=\mathbb{E}[X_sX_t]$ and characterizing the collection of finite-dimensional [marginal distributions](https://en.wikipedia.org/wiki/Marginal_distribution) of the process $X$
   - consider the case where $T=\mathbb{R}$ and $\mu$ is a finite symmetric measure on $\mathbb{R}$
   - then set for every $s,t\in\mathbb{R}$, $\Gamma(s,t)=\int \mathrm{e}^{\mathrm{i}\xi(t-s)}\,\mu(\mathrm{d}\xi)$
   - verify that $\Gamma$ has the required properties; if $c$ is a real function on $\mathbb{R}$ with finite support, we have $\sum_{\mathbb{R}\times\mathbb{R}}c(s)c(t)\Gamma(s,t)=\int|\sum_{\mathbb{R}}c(s)\mathrm{e}^{\mathrm{i}\xi s}|^2\mu(\mathrm{d}\xi)\ge 0$
   - the process $\Gamma$ enjoys the additional property that $\Gamma(s,t)$ only depends on $t-s$; it follows immediately that any centered Gaussian process $(X_t)_{t\in\mathbb{R}}$ with covariance function $\Gamma$ is [stationary](https://en.wikipedia.org/wiki/Stationary_process) in a strong sense, meaning that $(X_{t_1+t},\dots,X_{t_n+t})=(X_{t_1},\dots,X_{t_n})$ for any choice of $t_1,\dots,t_n\in\mathbb{R}$
   - any stationary Gaussian process $X$ indexed by $\mathbb{R}$ has a covariance of this type ([Bochner's theorem](https://en.wikipedia.org/wiki/Bochner%27s_theorem)) and the measure $\mu$ is called the spectral measure of $X$
"""

# ╔═╡ 41b4fe1b-169f-400b-81b9-35f3ca15847b
# add some code here

# ╔═╡ 1747a3b5-2dc9-4cf7-b192-ffbd206ee544
md"""
## Gaussian white noise
 - **Definition 1.12.** Let $(E,\mathscr{E})$ be a measurable space and $\mu$ be a $\sigma$-finite measure on $(E,\mathscr{E})$. A [Gaussian white noise](https://en.wikipedia.org/wiki/Additive_white_Gaussian_noise) with intensity $\mu$ is an [isometry](https://en.wikipedia.org/wiki/Isometry) $G$ from $L^2(E,\mathscr{E},\mu)$ into a centered Gaussian space.
   - if $f\in L^2(E,\mathscr{E},\mu)$, $G(f)$ is a centered Gaussian with variance $\mathbb{E}[G(f)^2]=||G(f)||^2_{L^2(\Omega,\mathscr{F},P)}=||f||^2_{L^2(E,\mathscr{E},\mu)}=\int f^2\,\mathrm{d}\mu$
   - if $f,g\in L^2(E,\mathscr{E},\mu)$, the covariance of $G(f)$ and $G(g)$ is $\mathbb{E}[G(f)G(g)]=\langle f,g\rangle_{L^2(E,\mathscr{E},\mu)}=\int fg\,\mathrm{d}\mu$
   - if $f=\mathbf{1}_A$ with $\mu(A)<\infty$, $G(\mathbf{1}_A)\sim\mathscr{N}(0,\mu(A))$
   - let $A_1,\dots,A_n\in\mathscr{E}$ be disjoint and such that $\mu(A_j)<\infty$ for every $j$; then, the vector $(G(\mathbf{1}_{A_1}),\dots,G(\mathbf{1}_{A_n}))$ is a Gaussian vector in $\mathbb{R}^n$ and its covariance matrix is diagonal since if $i\ne j$, $\mathbb{E}[G(\mathbf{1}_{A_i}\mathbf{1}_{A_j}]=\langle \mathbf{1}_{A_i},\mathbf{1}_{A_j}\rangle_{L^2(E,\mathscr{E},\mu)}=0$
 - **Proposition 1.13.** Let $(E,\mathscr{E})$ be a measurable space and $\mu$ be a $\sigma$-finite measure on $(E,\mathscr{E})$. There exists, on an appropriate probability space $(\Omega,\mathscr{F},P)$, a Gaussian white noise with intensity $\mu$
   - let $(f_i,i\in I)$ be a total [orthonormal system](https://en.wikipedia.org/wiki/Orthonormal_function_system) in the Hilbert space $L^2(E,\mathscr{E},\mu)$
   - for every $f\in L^2(E,\mathscr{E},\mu)$, $f=\sum_{i\in I}\alpha_if_i$, where the coefficients $\alpha_i=\langle f,f_i\rangle$ are such that $\sum_{i\in I}\alpha_i^2=||f||^2<\infty$
   - on an appropriate probability space $(\Omega,\mathscr{F},P)$ we can construct a collection $(X_i)_{i\in I}$, indexed by the same index set $I$, of independent $\mathscr{N}(0,1)$ random variables, and we set $G(f)=\sum_{i\in I}\alpha_i X_i$
   - the series converges in $L^2$ since the $X_i,i\in I$ form an orthonormal system in $L^2$; $G$ clearly takes values in the Gaussian space generated by $X_i,i\in I$; $G$ is an isometry since it maps the orthonormal basis $(f_i,i\in I)$ to an orthonormal system
 - **Proposition 1.14.** Let $G$ be a Gaussian white noise on $(E,\mathscr{E})$ with intensity $\mu$. Let $A\in\mathscr{E}$ be such that $\mu(A)<\infty$. Assume that there exists a sequence of [partitions](https://en.wikipedia.org/wiki/Partition_of_a_set) of $A$, $A=A_1^n\cup\cdots\cup A_{k_n}^n$, whose [mesh](https://en.wikipedia.org/wiki/Types_of_mesh#:~:text=A%20mesh%20is%20a%20representation,solution%20to%20the%20model%20instance.) tends to $0$, in the sense that $\lim_{n\to\infty}[\sup_{1\le j\le k_n}[\mu(A_j^n)]]=0$. Then, $\lim_{n\to\infty}[\sum_{j=1}^{k_n}{G(A_j^n)^2}]=\mu(A)$
   - for every fixed $n$, the variables $G(A_1^n),\dots,G(A_{k_n}^n)$ are independent with $\mathbb{E}[G(A_j^n)^2]=\mu(A_j^n)$
   - we then compute $\mathbb{E}[(\sum_{j=1}^{k_n}(G(A_j^n)^2-\mu(A)))^2]=\sum_{j=1}^{k_n}\mathrm{var}(G(A_j^n)^2)=2\sum_{j=1}^{k_n}\mu(A_j^n)^2$, since if $X$ is $\mathscr{N}(0,1)$, $\mathrm{var}(X^2)=\mathbb{E}[X^4]-\sigma^4=3\sigma^4-\sigma^4=2\sigma^4$
   - then $\sum_{j=1}^{k_n}\mu(A_j^n)^2\le(\sup_{1\le j\le k_n}[\mu(A_j^n)])\mu(A)$ tends to $0$ as $n\to\infty$ by assumption

"""

# ╔═╡ 432425ab-f6fd-4737-9e37-8faf03fcb9ba
# add some code here

# ╔═╡ bdfab4bc-2a99-11f0-2cba-03f457220f01
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(50px, 20%);
    	padding-right: max(50px, 20%);
	}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Distributions = "~0.25.115"
Plots = "~1.40.9"
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.3"
manifest_format = "2.0"
project_hash = "2ab78265d76878a921679c4a3bd52d9bd18f378c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "c785dfb1b3bfddd1da557e861b919819b82bbe5b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.27.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "f36e5e8fdffcb5646ea5da81495a5a7566005127"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.3"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "4b138e4643b577ccf355377c2bc70fa975af25de"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.115"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e51db81749b0777b2147fbe7b783ee79045b8e99"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "424c8f76017e39fdfcdbb5935a8e6742244959e8"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "b90934c8cb33920a8dc66736471dc3961b42ec9f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "b1c2585431c382e3fe5805874bda6aea90a95de9"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.25"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3447a92280ecaad1bd93d3fce3d408b6cfff8913"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.0+1"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4ec1e8fac04150b570e315baaa68950e368a803d"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a7f43994b47130e4f491c3b2dbe78fe9e2aed2b3"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "84eef7acd508ee5b3e956a2ae51b05024181dee0"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.2+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "edbf5309f9ddf1cab25afc344b1e8150b7c832f9"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.2+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f58782a883ecbf9fb48dcd363f9ccd65f36c23a8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "12f1439c4f986bb868acda6ea33ebc78e19b95ad"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.7.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ed6834e95bd326c52d5675b4181386dfbe885afb"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.55.5+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "dae01f8c2e069a683d3a6e17bbae5070ab94786f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.9"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "01915bfcd62be15329c9a07235447a89d588327c"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.1"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "d9717ce3518dc68a99e6b96300813760d887a01d"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.1+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "15e637a697345f6743674f1322beefbc5dcd5cfc"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.3+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+1"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2b0e27d52ec9d8d483e2ca0b72b3cb1a8df5c27a"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+1"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "02054ee01980c90297412e4c809c8694d7323af3"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+1"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d7155fea91a4123ef59f42c4afb5ab3b4ca95058"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+1"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee57a273563e273f0f53275101cd41a8153517a"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+1"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "1a74296303b6524a0472a8cb12d3d87a78eb3612"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+1"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b9ead2d2bdb27330545eb14234a2e300da61232e"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0ba42241cb6809f1a278d0bcb976e0483c3f1f2d"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "9c42636e3205e555e5785e902387be0061e7efc1"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─c57a4eb1-f711-4bfb-a0c9-0973b7011671
# ╟─da5c325b-0d47-4f63-8678-fcd83ea7f98b
# ╠═ea410cb2-05f9-41a2-b06e-7ecada7ade93
# ╠═4b5cdd8f-b26a-42a9-be50-37701adf7226
# ╟─5ea137ec-09d2-42d6-8c05-4d09b48b7741
# ╟─2ab954fb-8924-4a53-b4ae-e201c28802ca
# ╟─98425061-9b51-4b46-a31f-93a224c2ae1b
# ╟─ec0ea3e4-127f-4681-b6f8-f7f054309ec1
# ╟─26dc1d65-8bee-4518-8930-07ac5f965503
# ╠═260fc62b-b068-4901-828b-e53e964a0830
# ╟─76248865-3759-46b1-80b6-7a7c85362e53
# ╠═41b4fe1b-169f-400b-81b9-35f3ca15847b
# ╟─1747a3b5-2dc9-4cf7-b192-ffbd206ee544
# ╠═432425ab-f6fd-4737-9e37-8faf03fcb9ba
# ╟─bdfab4bc-2a99-11f0-2cba-03f457220f01
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
