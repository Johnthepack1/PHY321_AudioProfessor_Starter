import Foundation

/// Short, exam-style equation selection scenarios. These are original instructional scenarios,
/// not copied exam problems. Every scenario explains the physical clues and common wrong choice.
enum EquationDrills {
    static let topics: [Lesson] = [
        Lesson(
            id: "select_19_impulse_time", chapter: "Equation Finder · Ch 19", title: "Force acts for a known time",
            explanation: "Imagine a heavy cart receives a horizontal push for point four seconds. The problem asks for its velocity afterward. Your trigger words are force, time interval, and before and after velocity. Start with linear impulse momentum: initial mass times velocity plus the integral of net external force with respect to time equals final mass times velocity. For a constant force, the integral is force times time. Energy would require the force's displacement, which we were not given. Choose the equation by what the problem provides, not just by noticing the word velocity.",
            question: "Given a force acting for a known time, which method connects initial and final velocity?",
            acceptedPhrases: ["impulse momentum", "linear impulse", "impulse", "momentum"],
            correctExplanation: "Use linear impulse momentum. Net force accumulated over time changes linear momentum.",
            remediation: "Write mass times initial velocity plus integral of net force d t equals mass times final velocity. The time interval is the clue."
        ),
        Lesson(
            id: "select_19_torque_time", chapter: "Equation Finder · Ch 19", title: "Torque acts for several seconds",
            explanation: "A uniform disk spins around a fixed axle and an applied torque acts for three seconds. You are asked for the final angular speed. That is angular impulse momentum about the fixed axle: I sub O times initial omega plus the integral of net moment about O d t equals I sub O times final omega. The axle reaction usually creates zero moment about its own axis. Be sure you use the moment of inertia about the correct axis.",
            question: "Torque applied for a specified time suggests which rotational principle?",
            acceptedPhrases: ["angular impulse", "impulse momentum", "angular momentum"],
            correctExplanation: "Angular impulse momentum about the axle connects torque over time with the change in angular momentum.",
            remediation: "A moment integrated over time is angular impulse. It changes I times omega."
        ),
        Lesson(
            id: "select_19_force_graph", chapter: "Equation Finder · Ch 19", title: "Area under a force-time graph",
            explanation: "Suppose a force climbs linearly from zero to twenty newtons over two seconds. The impulse is the area under the force-versus-time graph: one half times base two seconds times height twenty newtons equals twenty newton seconds. Never multiply only the maximum force by the whole time when force is varying. That would make a rectangular area instead of the triangular one.",
            question: "Which graph quantity gives impulse from a changing force?",
            acceptedPhrases: ["area", "integral", "area under"],
            correctExplanation: "Use the area under the force-time graph, the integral of force over time.",
            remediation: "Find the area under force plotted against time. A triangle uses one half base times height."
        ),
        Lesson(
            id: "select_19_moment_graph", chapter: "Equation Finder · Ch 19", title: "Moment changes over time",
            explanation: "When the applied torque changes with time, calculate angular impulse with the integral of moment d t. A constant torque uses M times delta t. A changing torque must be integrated. Both have the units of newton meter seconds, and both change angular momentum. If the graph is a triangle, use its area; if an expression is given, integrate it.",
            question: "What mathematical operation finds angular impulse from a variable torque?",
            acceptedPhrases: ["integral", "integrate", "area under"],
            correctExplanation: "Integrate the moment with respect to time, or find the area under its time graph.",
            remediation: "Angular impulse equals the integral of net moment d t, not moment times distance."
        ),
        Lesson(
            id: "select_19_fixed_pivot", chapter: "Equation Finder · Ch 19", title: "Collision with a pinned rod",
            explanation: "A small ball hits a rod attached to a pin at O. During the very short collision, the pin can deliver a large unknown force impulse. So ordinary linear momentum of ball plus rod generally is not conserved. But the pin impulse has zero moment about O. If other external angular impulses are negligible, conserve angular momentum about O for the ball-and-rod system. Keep a before and after angular momentum diagram, and then use a restitution equation if rebound velocities are required.",
            question: "Which momentum is often conserved during impact with a pinned rod?",
            acceptedPhrases: ["angular momentum", "momentum about the pin", "momentum about pivot"],
            correctExplanation: "Angular momentum about the pin is useful when its net external angular impulse is negligible.",
            remediation: "Choose the pin as moment center. The large pin impulse has zero lever arm there, so it creates no angular impulse about that point."
        ),
        Lesson(
            id: "select_19_linear_conserve", chapter: "Equation Finder · Ch 19", title: "When linear momentum is conserved",
            explanation: "Two carts collide on a smooth horizontal track. During the short contact, the external horizontal impulse is negligible. That is the precise condition for conserving total horizontal linear momentum. Vertical momentum need not be conserved if the track gives a vertical impulse. Conservation is directional: first specify the system and direction, then test the net external impulse.",
            question: "What must be negligible to conserve linear momentum in a direction?",
            acceptedPhrases: ["external impulse", "net external impulse", "outside impulse", "external force impulse"],
            correctExplanation: "The net external impulse in that direction must be zero or negligible.",
            remediation: "Use total linear impulse momentum for the whole system. If the external impulse vanishes in one direction, its momentum component is conserved."
        ),
        Lesson(
            id: "select_19_angular_conserve", chapter: "Equation Finder · Ch 19", title: "When angular momentum is conserved",
            explanation: "A person on a freely rotating platform draws both arms inward. If external angular impulse about the vertical axis is negligible, angular momentum about that axis is conserved even though moment of inertia changes. Thus I initial times omega initial equals I final times omega final for the simplified system. Do not confuse conservation of angular momentum with conservation of kinetic energy. Angular kinetic energy may change because the person does work.",
            question: "What must be negligible to conserve angular momentum about a point?",
            acceptedPhrases: ["external angular impulse", "external moment impulse", "net torque impulse", "moment over time"],
            correctExplanation: "Net external angular impulse about the selected point must be negligible.",
            remediation: "Conservation of angular momentum requires the time integral of external moments about that point to be zero."
        ),
        Lesson(
            id: "select_19_center", chapter: "Equation Finder · Ch 19", title: "A rotating body with a moving center",
            explanation: "A rigid body may translate and spin at the same time. Linear momentum equals mass times center-of-mass velocity. Angular momentum about G is I sub G times omega. About a fixed inertial point O, angular momentum is I sub G omega plus the position vector from O to G cross mass times the velocity of G. Do not use I sub O omega alone for an arbitrary moving body unless the geometry truly justifies a fixed axis.",
            question: "What point's velocity determines a rigid body's total linear momentum?",
            acceptedPhrases: ["center of mass", "mass center", "center g"],
            correctExplanation: "The center-of-mass velocity determines linear momentum: m v sub G.",
            remediation: "For any rigid body, linear momentum equals total mass times the velocity of its mass center."
        ),
        Lesson(
            id: "select_19_restitution", chapter: "Equation Finder · Ch 19", title: "Collision and rebound speed",
            explanation: "If a problem mentions a coefficient of restitution and asks how quickly bodies separate after an impact, use the restitution relation along the line of impact. Restitution relates relative separation speed to relative approach speed, and it is not a momentum conservation law. Combine it with the appropriate impulse-momentum or conservation equation to get enough equations for the unknown post-impact velocities.",
            question: "What relation uses a coefficient e to describe relative velocities in impact?",
            acceptedPhrases: ["restitution", "coefficient of restitution"],
            correctExplanation: "Use the restitution equation along the line of impact, together with the relevant momentum equation.",
            remediation: "The coefficient e links relative approach and relative separation speeds; it does not replace the momentum equation."
        ),
        Lesson(
            id: "select_19_rolling", chapter: "Equation Finder · Ch 19", title: "Rolling without slipping",
            explanation: "After an angular impulse or collision, a wheel may roll without slipping. Include the kinematic constraint that mass-center speed equals radius times angular speed in magnitude. The constraint is not a conservation law. Determine consistent positive directions before attaching signs to v sub G and omega. If the wheel actually slips, this constraint is not valid.",
            question: "Which relationship links wheel-center speed and angular speed for no slipping?",
            acceptedPhrases: ["v equals r omega", "radius times omega", "v equals radius times omega", "rolling constraint"],
            correctExplanation: "Use the rolling constraint: center speed equals R times angular speed in magnitude.",
            remediation: "For rolling without slipping, the ground-contact point is instantaneously at rest and speed magnitude v sub G is R omega."
        ),
        Lesson(
            id: "select_19_energy_or_impulse", chapter: "Equation Finder · Ch 19", title: "Distance versus time clue",
            explanation: "A force over a measured displacement suggests work-energy, while a force over a measured time suggests impulse-momentum. If the event is a very fast impact, angular momentum about an advantageous point or a momentum conservation equation may apply. This decision tree is powerful because both methods involve initial and final velocities; the given distance versus time is usually the clearest clue.",
            question: "If force and time are known but displacement is not, which method usually fits better?",
            acceptedPhrases: ["impulse", "momentum"],
            correctExplanation: "Impulse-momentum naturally uses force integrated over time.",
            remediation: "Time corresponds to impulse. Displacement corresponds to work."
        ),
        Lesson(
            id: "select_22_natural", chapter: "Equation Finder · Ch 22", title: "Mass and spring natural frequency",
            explanation: "A mass is attached to a linear spring and moves freely without damping. The equation is m x double dot plus k x equals zero. Natural angular frequency equals the square root of k over m. If m is four kilograms and k is one hundred newtons per meter, omega naught equals five radians per second. Convert to period using two pi over omega naught, and to hertz using omega naught over two pi.",
            question: "What is the natural angular frequency of an undamped mass-spring system?",
            acceptedPhrases: ["square root of k over m", "square root k divided by m", "root k over m", "square root of stiffness divided by mass"],
            correctExplanation: "Omega naught equals square root of stiffness divided by mass.",
            remediation: "Begin with m x double dot plus k x equals zero; compare with x double dot plus omega naught squared x equals zero."
        ),
        Lesson(
            id: "select_22_frequency", chapter: "Equation Finder · Ch 22", title: "Period versus frequency",
            explanation: "If an oscillator makes five cycles in ten seconds, its period is two seconds per cycle and its frequency is point five hertz. Ordinary frequency is cycles divided by time, or one over period. Angular frequency is two pi times ordinary frequency, in radians per second. Identify which unit the question asks for before selecting the final formula.",
            question: "Which equation gives the period from angular frequency omega?",
            acceptedPhrases: ["two pi over omega", "2 pi divided by omega", "two pi divided by angular frequency"],
            correctExplanation: "Period T equals two pi divided by angular frequency omega.",
            remediation: "One cycle covers two pi radians. Divide that angle by radians per second to obtain seconds per cycle."
        ),
        Lesson(
            id: "select_22_amplitude", chapter: "Equation Finder · Ch 22", title: "Amplitude from initial conditions",
            explanation: "For free undamped vibration, write displacement as C one cosine omega naught t plus C two sine omega naught t. Initial displacement gives C one. Initial velocity divided by omega naught gives C two. Then amplitude is square root of C one squared plus C two squared. This avoids mistaking initial displacement for amplitude when the mass also has initial velocity.",
            question: "For x equals C one cosine plus C two sine, how do you find amplitude?",
            acceptedPhrases: ["square root", "root", "pythagorean"],
            correctExplanation: "Amplitude is square root of C one squared plus C two squared.",
            remediation: "The sine and cosine coefficients are perpendicular components of one oscillation; combine by Pythagoras."
        ),
        Lesson(
            id: "select_22_max_velocity", chapter: "Equation Finder · Ch 22", title: "Maximum velocity and acceleration",
            explanation: "For simple harmonic motion with amplitude A and angular frequency omega, velocity amplitude is A times omega, and acceleration amplitude is A times omega squared. If the amplitude doubles and frequency stays fixed, both maximum speed and maximum acceleration double. If frequency doubles, maximum speed doubles but maximum acceleration becomes four times as large.",
            question: "What equation gives the maximum acceleration magnitude for SHM?",
            acceptedPhrases: ["amplitude times omega squared", "omega squared times amplitude", "a omega squared", "a times angular frequency squared"],
            correctExplanation: "Maximum acceleration magnitude is amplitude times omega squared.",
            remediation: "Differentiate the sinusoidal displacement twice. Each derivative contributes one omega; the magnitude is A omega squared."
        ),
        Lesson(
            id: "select_22_springs", chapter: "Equation Finder · Ch 22", title: "Equivalent springs",
            explanation: "If two springs support the same mass side by side and stretch together, the forces add and equivalent stiffness is k one plus k two. In series, both carry the same force and their extensions add, so reciprocal equivalent stiffness is reciprocal k one plus reciprocal k two. First decide whether the drawing represents the same deflection or the same force, then calculate frequency using equivalent stiffness.",
            question: "Which spring arrangement has stiffness k one plus k two?",
            acceptedPhrases: ["parallel", "side by side"],
            correctExplanation: "Parallel springs add their stiffnesses directly.",
            remediation: "Parallel springs move the same distance, so their forces add."
        ),
        Lesson(
            id: "select_22_pendulum", chapter: "Equation Finder · Ch 22", title: "Simple pendulum at small angles",
            explanation: "For a simple pendulum with negligible damping and small angular displacement in radians, the restoring torque gives angular acceleration plus g over L times angular displacement equals zero. Therefore small-angle angular natural frequency is square root of g over L, and the period is two pi times square root of L over g. This is an approximation; large-angle oscillations need a more complete model.",
            question: "For a small-angle simple pendulum, what two quantities set natural frequency?",
            acceptedPhrases: ["gravity and length", "length and gravity", "g over l", "g divided by length"],
            correctExplanation: "Gravity and length set small-angle pendulum frequency: omega naught equals square root of g over L.",
            remediation: "Compare theta double dot plus g over L times theta equals zero with simple harmonic motion."
        ),
        Lesson(
            id: "select_22_rigid", chapter: "Equation Finder · Ch 22", title: "Rigid body swinging about a pivot",
            explanation: "For a rigid body oscillating about a fixed pivot with small angles, the restoring gravitational moment is approximately minus m g d times theta. Its rotational equation is I sub O times theta double dot plus m g d times theta equals zero. Thus the angular natural frequency is square root of m g d divided by I sub O. Here d is the distance from pivot to mass center; inertia must be about the pivot.",
            question: "For a rigid body oscillating about a fixed pivot, which inertia belongs in the frequency equation?",
            acceptedPhrases: ["moment of inertia about pivot", "inertia about the pivot", "i o", "pivot inertia"],
            correctExplanation: "Use mass moment of inertia about the fixed pivot, I sub O.",
            remediation: "Sum moments about the fixed pivot: I sub O times angular acceleration equals the restoring moment."
        ),
        Lesson(
            id: "select_22_ode", chapter: "Equation Finder · Ch 22", title: "Second-order homogeneous equation",
            explanation: "When you see m x double dot plus c x dot plus k x equals zero, the right-hand side is zero: this is a homogeneous constant-coefficient differential equation. Try e to the r t, obtain m r squared plus c r plus k equals zero, find its roots, and use the roots to build the general solution. Initial displacement and velocity determine the integration constants.",
            question: "What algebraic equation do you solve after trying e to the r t?",
            acceptedPhrases: ["characteristic", "auxiliary"],
            correctExplanation: "Solve the characteristic equation m r squared plus c r plus k equals zero.",
            remediation: "The trial exponential turns each time derivative into multiplication by r; the result is a quadratic in r."
        ),
        Lesson(
            id: "select_22_damping", chapter: "Equation Finder · Ch 22", title: "Light, critical, or heavy damping",
            explanation: "To classify free damped motion, compute critical damping c critical equals two square root of m k. Damping ratio zeta equals c divided by c critical. When zeta is less than one, motion is underdamped and oscillates with a decaying envelope. At zeta equal to one it is critically damped. Greater than one is overdamped, also called heavy damping. These are three solution forms of the homogeneous equation.",
            question: "If damping ratio zeta is less than one, what type of free response occurs?",
            acceptedPhrases: ["underdamped", "under damped", "light damping"],
            correctExplanation: "Underdamped response: it oscillates while the amplitude decays.",
            remediation: "Compare the damping coefficient with critical damping. A ratio below one produces complex characteristic roots."
        ),
        Lesson(
            id: "select_22_damped_frequency", chapter: "Equation Finder · Ch 22", title: "Underdamped frequency",
            explanation: "Light damping reduces the oscillation frequency. Compute undamped natural frequency omega naught equals square root of k over m, then damped frequency omega d equals omega naught times square root of one minus zeta squared. The decaying free response is e to negative zeta omega naught t times a sine and cosine combination at omega d. This formula applies only when damping ratio is below one.",
            question: "Which square-root factor multiplies omega naught to give damped frequency?",
            acceptedPhrases: ["one minus zeta squared", "square root of one minus", "root one minus damping"],
            correctExplanation: "Multiply omega naught by square root of one minus zeta squared.",
            remediation: "Use omega d equals omega naught square root of one minus zeta squared for underdamped motion."
        ),
        Lesson(
            id: "select_22_roots", chapter: "Equation Finder · Ch 22", title: "Recognize the three damping solutions",
            explanation: "For overdamping, the characteristic equation has two distinct negative real roots, and the solution is a sum of two decaying exponentials. For critical damping, there is one repeated negative real root; multiply one exponential by a linear term in time. For underdamping, the roots are complex conjugates; write a decaying exponential times a sine-cosine combination. Do not use the oscillating form when the roots are real.",
            question: "Which damping case gives a repeated characteristic root?",
            acceptedPhrases: ["critical", "critically damped"],
            correctExplanation: "Critical damping gives the repeated real root.",
            remediation: "The discriminant is exactly zero at critical damping, so the quadratic has one repeated root."
        ),
        Lesson(
            id: "select_22_forced", chapter: "Equation Finder · Ch 22", title: "Forced versus free vibration",
            explanation: "When the right-hand side of m x double dot plus c x dot plus k x is an applied time-varying force, the equation is inhomogeneous and the vibration is forced. Write the response as homogeneous, also called transient, plus a particular solution driven by the force. The homogeneous part reflects initial conditions. The steady-state particular part remains while the periodic forcing continues when damping makes the transient decay.",
            question: "In a forced differential equation, what two parts make the general solution?",
            acceptedPhrases: ["homogeneous and particular", "transient and particular", "free plus forced", "transient plus steady"],
            correctExplanation: "The response is the homogeneous or transient part plus a particular or forced part.",
            remediation: "Solve the homogeneous equation, find one particular solution for the forcing, then add the two."
        ),
        Lesson(
            id: "select_22_resonance", chapter: "Equation Finder · Ch 22", title: "Identify resonance",
            explanation: "A periodic force acts on a vibrating spring-mass system. When driving frequency approaches the natural frequency, the amplitude may become large: this is resonance. In an ideal undamped model the response at exact resonance grows without bound over time; in a real damped system the steady-state amplitude is finite. The driving frequency is set by the external force, while natural frequency is set by system properties.",
            question: "What effect occurs when driving frequency nears natural frequency?",
            acceptedPhrases: ["resonance", "resonant"],
            correctExplanation: "Resonance can produce a large response when forcing frequency is near a system's natural frequency.",
            remediation: "Compare the applied driving frequency with the natural frequency. A close match is the resonance clue."
        ),
        Lesson(
            id: "select_22_amplitude_forced", chapter: "Equation Finder · Ch 22", title: "Amplitude of damped forced vibration",
            explanation: "For m x double dot plus c x dot plus k x equals F zero cosine Omega t, the steady-state displacement amplitude is F zero divided by square root of the quantity k minus m Omega squared, all squared, plus c Omega squared. More precisely, the denominator is the square root of open parenthesis k minus m Omega squared close parenthesis squared plus open parenthesis c Omega close parenthesis squared. This formula uses the actual driving frequency capital Omega, not just natural frequency. A forcing question asking amplitude suggests this equation, not the free-vibration amplitude from initial conditions.",
            question: "Which frequency belongs in the steady-state forced-amplitude formula?",
            acceptedPhrases: ["driving", "forcing", "applied frequency"],
            correctExplanation: "Use the forcing or driving frequency, not automatically the natural frequency.",
            remediation: "The applied force oscillates at its own specified frequency, capital Omega; use that in the forcing amplitude formula."
        ),
        Lesson(
            id: "select_22_steady", chapter: "Equation Finder · Ch 22", title: "Long-time vibration response",
            explanation: "A damped, periodically forced oscillator initially has a transient response plus a steady-state response. After enough time, the transient decays. Therefore if the problem asks what remains long after the force started, calculate the steady-state particular solution. If it asks for the full early-time motion, include the homogeneous solution and initial conditions.",
            question: "After a long time in a stable damped forced oscillator, which part remains?",
            acceptedPhrases: ["steady state", "particular", "forced response"],
            correctExplanation: "The steady-state particular response remains after the transient has decayed.",
            remediation: "Damping removes the homogeneous transient; the particular response is sustained by the force."
        ),
        Lesson(
            id: "select_22_static_shift", chapter: "Equation Finder · Ch 22", title: "Displacement measured from equilibrium",
            explanation: "For a vertical spring with gravity, define the vibration coordinate from the static equilibrium position. At equilibrium, spring force balances weight. The constant weight term then cancels out of the small-motion equation, leaving m x double dot plus k x equals zero for undamped free motion. If you measure from the undeformed spring length instead, you need to include gravity explicitly. Always identify the reference position before writing the equation.",
            question: "Where should displacement be measured to eliminate constant gravity in vertical spring vibration?",
            acceptedPhrases: ["equilibrium", "static equilibrium"],
            correctExplanation: "Measure displacement from the static equilibrium position.",
            remediation: "At static equilibrium, spring force balances weight; using that position as zero removes the constant force from the motion equation."
        )
    ]
}
