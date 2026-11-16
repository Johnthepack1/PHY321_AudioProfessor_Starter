import Foundation

struct Lesson: Identifiable {
    let id: String
    let chapter: String
    let title: String
    let explanation: String
    let question: String
    let acceptedPhrases: [String]
    let correctExplanation: String
    let remediation: String
}

enum Curriculum {
    static let topics: [Lesson] = [
        Lesson(
            id: "math_variables",
            chapter: "Math foundation",
            title: "What is an equation?",
            explanation: "An equation is a statement saying that two expressions have the same value. Imagine a balance scale. What you do to the left side must also be done to the right side. A variable, such as x, is a name for a number we do not yet know. Suppose three x equals twelve. Divide both sides by three, so x equals four. Notice that we do not move the three across the equals sign by magic. We use an inverse operation on both sides. In physics, when you rearrange force equals mass times acceleration to solve for acceleration, the same algebra gives acceleration equals force divided by mass. Whenever a formula feels unfamiliar, first ask: which quantity do I want by itself, and what inverse operations isolate it?",
            question: "If force equals mass times acceleration, what operation isolates acceleration?",
            acceptedPhrases: ["divide by mass", "dividing by mass", "force over mass", "force divided by mass"],
            correctExplanation: "Yes. Divide both sides by mass. Acceleration equals force divided by mass.",
            remediation: "Imagine force equals mass times acceleration as a balance. Cancel the multiplication by mass using division on BOTH sides. Then acceleration equals force divided by mass."
        ),
        Lesson(
            id: "math_units",
            chapter: "Math foundation",
            title: "Units, mass, and weight",
            explanation: "Physics equations connect measured quantities, not just bare numbers. Mass measures how much matter an object has and its resistance to changes in motion. Weight is a force due to gravity. In SI units, mass is in kilograms and force is in newtons. In United States customary units, weight may be in pounds of force and mass in slugs. To convert weight in pounds to mass in slugs near Earth, divide by about thirty-two point two feet per second squared. Be careful because a number labeled pounds is not automatically a mass in dynamics. Always write units during algebra. If your final angular velocity has units of meters per second, you have probably solved for the wrong quantity.",
            question: "Near Earth in U.S. customary units, do you divide weight by gravity to obtain mass, or multiply it?",
            acceptedPhrases: ["divide", "dividing", "weight over gravity"],
            correctExplanation: "Correct. Mass equals weight divided by local gravitational acceleration.",
            remediation: "Weight equals mass times gravitational acceleration, W equals m g. Divide both sides by g to isolate mass."
        ),
        Lesson(
            id: "math_trig",
            chapter: "Trigonometry",
            title: "Sine, cosine, and force components",
            explanation: "Trigonometry helps break a diagonal force into horizontal and vertical pieces. Start with a right triangle. Sine is opposite over hypotenuse. Cosine is adjacent over hypotenuse. Suppose a force points up and to the right at an angle measured above the positive horizontal axis. Its horizontal component is force times cosine of the angle. Its vertical component is force times sine of the angle. However, if the angle is measured from the vertical, those labels switch. Do not memorize components without looking at the angle in the diagram. Before choosing sine or cosine, say aloud which side is opposite and which is adjacent. For a force pointing left, the horizontal component is negative even if its magnitude is positive.",
            question: "When the angle is measured from the horizontal, does the horizontal component use sine or cosine?",
            acceptedPhrases: ["cosine", "cos"],
            correctExplanation: "Exactly. The horizontal component is adjacent to the angle, so use cosine.",
            remediation: "The horizontal side touches the angle and is not the hypotenuse. Adjacent over hypotenuse is cosine, so F x equals F cosine theta."
        ),
        Lesson(
            id: "math_radians",
            chapter: "Trigonometry",
            title: "Radians and angular motion",
            explanation: "A radian measures an angle using arc length divided by radius. One full revolution is two pi radians, or three hundred sixty degrees. A rotating wheel uses angular position theta, angular velocity omega, and angular acceleration alpha. Angular velocity is measured in radians per second. If a point on a wheel is radius r from the center, the speed tangent to its circular path is r times omega. This relationship connects angular motion to ordinary linear speed. It also explains why the edge of a large wheel moves faster than a point near its center at the same omega. Calculators must use radians when differentiating or integrating sine and cosine in time.",
            question: "How many radians are in one complete revolution?",
            acceptedPhrases: ["two pi", "2 pi", "two times pi", "six point two eight"],
            correctExplanation: "Right. A complete revolution is two pi radians.",
            remediation: "The circumference of a circle is two pi times radius. Arc length divided by radius gives two pi radians."
        ),
        Lesson(
            id: "math_derivative",
            chapter: "Calculus",
            title: "Derivative means rate of change",
            explanation: "A derivative answers the question: how fast is something changing right now? If position x depends on time, its derivative with respect to time is velocity. Differentiate velocity again and you obtain acceleration. This means acceleration is the second derivative of position. Imagine your distance from a stop sign. If your distance changes quickly, you have a large speed. If that speed changes, you have acceleration. In Chapter twenty-two, the unknown function is often displacement as a function of time. When you hear x double dot, that simply means the second derivative of x with respect to time. Nothing mysterious has been added. Newton's second law is written in terms of that second derivative.",
            question: "What physical quantity is the second derivative of position with respect to time?",
            acceptedPhrases: ["acceleration", "accelerating"],
            correctExplanation: "Correct. The first derivative is velocity, and the second derivative is acceleration.",
            remediation: "Take the first derivative of position to get velocity. Take the derivative of velocity to get acceleration. That is the second derivative of position."
        ),
        Lesson(
            id: "math_chain",
            chapter: "Calculus",
            title: "Chain rule in oscillations",
            explanation: "The chain rule handles a function inside another function. Suppose displacement is the sine of omega times t. The outside function is sine; its derivative is cosine. Then multiply by the derivative of the inside expression, omega times t, which is omega if omega is constant. So the time derivative of sine of omega t is omega times cosine of omega t. Differentiating again introduces another omega and a minus sign, giving negative omega squared times sine of omega t. That is why sine and cosine are natural functions for vibration. Their second derivatives point opposite to their original displacement, matching a restoring spring force.",
            question: "When differentiating sine of omega times t, what factor appears from the chain rule?",
            acceptedPhrases: ["omega", "angular frequency"],
            correctExplanation: "Yes. Multiply by omega because the inside expression omega t changes at rate omega.",
            remediation: "The derivative of sine is cosine, but the inside function omega t also changes. Multiply by its derivative, omega."
        ),
        Lesson(
            id: "math_integral",
            chapter: "Calculus",
            title: "Integrals mean accumulation",
            explanation: "An integral adds many tiny contributions. If a force acts over time, each tiny time interval adds a small piece of impulse, approximately force times a tiny change in time. Integrating force over time totals those pieces. For a constant force, impulse is force times elapsed time. For a changing force, you must integrate its function of time. The area under a force-versus-time graph is impulse. This is the mathematical bridge from Newton's second law to the impulse-momentum equation used in Chapters fifteen and nineteen. It is different from work, where you integrate force over displacement rather than time.",
            question: "Impulse is the integral of force with respect to what variable?",
            acceptedPhrases: ["time", "seconds", "t"],
            correctExplanation: "Exactly. Impulse is force accumulated over time.",
            remediation: "Use the question to identify the horizontal axis. Force integrated over TIME gives impulse. Force integrated along displacement gives work."
        ),
        Lesson(
            id: "math_quadratic",
            chapter: "Algebra and differential equations",
            title: "The quadratic formula and damping",
            explanation: "You may remember solving a quadratic equation: a times r squared plus b times r plus c equals zero. The quadratic formula uses negative b plus or minus the square root of b squared minus four a c, divided by two a. The expression under the square root is called the discriminant. Its sign determines whether you get two different real roots, one repeated real root, or a complex conjugate pair. In Chapter twenty-two, the characteristic equation of a damped spring is m r squared plus c r plus k equals zero. The exact same algebra classifies overdamped, critically damped, and underdamped motion. This is a direct connection from basic algebra to advanced vibrations.",
            question: "What part of the quadratic formula tells you whether the roots are real or complex?",
            acceptedPhrases: ["discriminant", "b squared minus four a c", "b2-4ac"],
            correctExplanation: "Yes. The discriminant is b squared minus four a c.",
            remediation: "Look inside the square root of the quadratic formula. A positive, zero, or negative value changes the type of roots. That expression is the discriminant."
        ),
        Lesson(
            id: "physics_newton",
            chapter: "Chapter 13 connection",
            title: "Newton leads into vibrations",
            explanation: "Newton's second law states that the sum of external forces equals mass times acceleration. Imagine a block pulled to the right by a spring. The spring exerts a restoring force to the left. If x is the displacement measured from equilibrium and positive to the right, the spring force is negative k x. Newton's law becomes mass times acceleration equals negative k x. Move the spring term to the left and you get mass times acceleration plus k x equals zero. Since acceleration is the second derivative of displacement, this is a second-order differential equation. So vibrations are not an isolated chapter: they come directly from Newton's law, Hooke's law, and calculus.",
            question: "Why is the restoring force of a spring written with a negative sign?",
            acceptedPhrases: ["opposite", "restor", "back toward", "against the displacement", "toward equilibrium"],
            correctExplanation: "Exactly. The spring force acts opposite to displacement from equilibrium.",
            remediation: "If you pull the mass right, the spring pulls left. If you pull left, it pulls right. The restoring force opposes displacement."
        ),
        Lesson(
            id: "physics_moment",
            chapter: "Chapters 16–17 connection",
            title: "Torque and rotational acceleration",
            explanation: "Force changes linear motion. A moment, also called torque, changes rotational motion. A force applied at a distance from a pivot has a turning effect equal to the force times its perpendicular lever arm. The lever arm is the shortest distance from the pivot to the force's line of action. In many fixed-axis problems, the sum of moments about the fixed axis equals the mass moment of inertia about that axis times angular acceleration. Compare this with Newton's second law, force equals mass times acceleration. Mass moment of inertia is the rotational analogue of mass. But be careful: the moment of inertia depends on how far the material lies from the chosen axis.",
            question: "What distance should you use when calculating the moment of a force about a pivot?",
            acceptedPhrases: ["perpendicular", "shortest distance", "lever arm"],
            correctExplanation: "Yes. Use the perpendicular distance from the pivot to the force line of action.",
            remediation: "Draw the force arrow as an infinite straight line. Drop a perpendicular from the pivot to that line. That length is the lever arm."
        ),
        Lesson(
            id: "physics_inertia",
            chapter: "Chapter 17 connection",
            title: "Mass moment of inertia",
            explanation: "A body is harder to spin up when more of its mass is far from the rotation axis. Mass moment of inertia measures this distribution. For a rigid body, its value changes when you choose a different parallel rotation axis. The parallel-axis theorem says inertia about an axis through O equals inertia about the mass center G plus mass times the square of the distance between those axes. In Chapter nineteen you often need I about G for general plane motion, or I about the fixed pivot O for fixed-axis rotation. A slender uniform rod has inertia about its center equal to one twelfth m L squared and about its end equal to one third m L squared.",
            question: "When moving from a center-of-mass axis to a parallel axis some distance away, what theorem do you use?",
            acceptedPhrases: ["parallel axis", "parallel-axis"],
            correctExplanation: "Correct. Use the parallel-axis theorem, I O equals I G plus m d squared.",
            remediation: "The axis changes, so inertia changes. The rule for two parallel axes is the parallel-axis theorem."
        ),
        Lesson(
            id: "physics_energy",
            chapter: "Chapter 18 connection",
            title: "Energy and impulse are different tools",
            explanation: "Work-energy connects motion before and after a displacement. Impulse-momentum connects motion before and after a time interval. These describe the same physics from different viewpoints. If a problem gives forces and distances but not time, work-energy may be efficient. If it gives an applied force or torque and a duration, impulse-momentum may be efficient. In a collision, some kinetic energy may be lost even when momentum is conserved about an appropriate point. That is why you must not automatically use conservation of kinetic energy for a ball striking a rod. The clue is not just the presence of velocity; ask whether the useful information is distance, time, or a very short impact event.",
            question: "If a force acts over a known time interval, what method is usually more direct: work-energy or impulse-momentum?",
            acceptedPhrases: ["impulse", "momentum"],
            correctExplanation: "Correct. Time and applied force point toward impulse-momentum.",
            remediation: "Work accumulates force through distance. Impulse accumulates force through time. The word time is the important clue."
        ),
        Lesson(
            id: "ch19_linear",
            chapter: "Chapter 19",
            title: "Linear momentum of a rigid body",
            explanation: "Linear momentum of a rigid body is mass times the velocity of its center of mass G. This is a vector, meaning its direction matters. Even when a wheel rotates, the wheel can have linear momentum if its mass center moves. But if a wheel is mounted on a fixed axle passing through its center of mass, its center does not translate and its total linear momentum is zero. This is not the same as saying the wheel has no rotational motion. It can have zero linear momentum and nonzero angular momentum. When applying impulse-momentum in a plane, write separate equations for horizontal and vertical directions, keeping signs consistent.",
            question: "If a disk spins about a fixed axle through its center, what is the linear momentum of the whole disk?",
            acceptedPhrases: ["zero", "none"],
            correctExplanation: "Right. Its center of mass has zero velocity, so linear momentum is zero, even though it spins.",
            remediation: "Linear momentum uses velocity of the center of mass, not the speed of the outer rim. A fixed center has zero velocity."
        ),
        Lesson(
            id: "ch19_angular",
            chapter: "Chapter 19",
            title: "Angular momentum",
            explanation: "Angular momentum measures the rotational aspect of motion. For a planar rigid body, angular momentum about its mass center G equals mass moment of inertia about G times angular velocity. About a fixed rotation axis through O, you can write angular momentum about O as inertia about O times angular velocity. For a moving body and an arbitrary point A, you may need two contributions: I G times omega, plus the cross product of the position from A to G with m times center-of-mass velocity. This is why the choice of point matters. Angular momentum is the quantity changed by angular impulse, the integral of external moment over time.",
            question: "For a rigid body about its center of mass, what two quantities multiply to give angular momentum?",
            acceptedPhrases: ["inertia", "omega", "angular velocity", "moment of inertia"],
            correctExplanation: "Yes. Angular momentum about G equals I G times omega: mass moment of inertia times angular velocity.",
            remediation: "Think of linear momentum m times v. For rotation, replace mass with mass moment of inertia and velocity with angular velocity."
        ),
        Lesson(
            id: "ch19_impulse",
            chapter: "Chapter 19",
            title: "Angular impulse: torque over time",
            explanation: "Chapter nineteen takes the sum of moments equation and integrates it through a time interval. For a rigid body about its mass center, angular momentum at the start plus the integral of external moment with respect to time equals angular momentum at the end. If the body starts at rest, its initial angular velocity is zero. If the torque stays constant, its angular impulse is torque multiplied by elapsed time. If the torque changes with time, you integrate the torque function. This is exactly where the calculus lesson on accumulation becomes useful. For a rolling wheel with no slipping, you also need the geometric relationship: center speed equals wheel radius times angular velocity.",
            question: "If an applied torque changes with time, should you multiply by elapsed time or integrate the torque over time?",
            acceptedPhrases: ["integrate", "integration", "integral"],
            correctExplanation: "Correct. Integrate the time-varying torque to obtain angular impulse.",
            remediation: "Multiplication by time works only for a constant torque. If torque varies, find the area under the torque-versus-time curve by integration."
        ),
        Lesson(
            id: "ch19_conservation",
            chapter: "Chapter 19",
            title: "Conservation and short impacts",
            explanation: "Conservation of linear momentum requires zero net external linear impulse in the chosen direction. Conservation of angular momentum about a point requires zero net external angular impulse about that point. During a very short collision involving a rod pinned at O, the pivot can exert a significant force impulse, so linear momentum of the rod-and-projectile system need not be conserved. But the pivot force has no moment about O, which makes angular momentum about O useful if other external angular impulses are negligible. If a ball rebounds, a coefficient of restitution can relate the components of relative velocity along the impact line before and after collision. Never assume kinetic energy is conserved just because angular momentum is.",
            question: "During a short collision with a pinned rod, why is angular momentum about the pin often useful?",
            acceptedPhrases: ["zero moment", "no moment", "pivot force", "hinge force", "lever arm zero"],
            correctExplanation: "Exactly. The pivot impulse has no moment about the pivot, so it does not change angular momentum about that point.",
            remediation: "The pivot may exert a large force, but its lever arm about itself is zero. Therefore the pivot angular impulse about that point is zero."
        ),
        Lesson(
            id: "ch22_shm",
            chapter: "Chapter 22",
            title: "Free vibration and natural frequency",
            explanation: "A vibration is motion that repeats around an equilibrium position. For a simple undamped mass-and-spring system, the equation is mass times the second time derivative of displacement plus stiffness times displacement equals zero. Its natural angular frequency is the square root of stiffness divided by mass, measured in radians per second. The period is two pi divided by that angular frequency, measured in seconds per cycle. Ordinary frequency in hertz is one divided by period. These are three related but different quantities: angular frequency, period, and cycles per second. Higher stiffness gives a faster oscillation, while higher mass gives a slower one.",
            question: "If spring stiffness increases while mass stays constant, does natural angular frequency increase or decrease?",
            acceptedPhrases: ["increase", "increases", "goes up", "faster", "higher"],
            correctExplanation: "Correct. Natural angular frequency is the square root of stiffness divided by mass.",
            remediation: "Think of a stiffer spring pulling back more strongly. The system tends to reverse direction more quickly, so frequency rises."
        ),
        Lesson(
            id: "ch22_springs",
            chapter: "Chapter 22",
            title: "Springs in parallel and series",
            explanation: "When springs act in parallel on the same mass, they experience the same displacement and their forces add. Therefore equivalent stiffness equals the sum of the individual stiffnesses. When springs act in series, the same force goes through each spring while the total deflection is the sum of individual deflections. For two springs in series, one over equivalent stiffness equals one over k one plus one over k two. For example, four thousand and six thousand newtons per meter together in parallel give ten thousand. In series they give twenty-four hundred. Once you find equivalent stiffness, use the square root of stiffness over mass to calculate natural angular frequency.",
            question: "For springs in parallel, do you add their stiffness values or their reciprocals?",
            acceptedPhrases: ["add stiffness", "add their stiffness", "add values", "sum", "stiffnesses add"],
            correctExplanation: "Yes. Springs in parallel add directly: k equivalent equals k one plus k two.",
            remediation: "Parallel springs have the same displacement and their restoring forces add. That makes the equivalent stiffness equal to the direct sum."
        ),
        Lesson(
            id: "ch22_ode",
            chapter: "Chapter 22 math",
            title: "Solve a second-order homogeneous equation",
            explanation: "Now connect the differential equation to the quadratic formula. For a constant-coefficient homogeneous equation such as mass times x double dot plus damping times x dot plus stiffness times x equals zero, try a solution proportional to e raised to r t. Differentiating once multiplies by r; differentiating twice multiplies by r squared. Substitute this trial function into the equation, factor out the nonzero exponential, and obtain the characteristic quadratic: m r squared plus c r plus k equals zero. The roots determine the time dependence. This is why knowing algebraic roots, derivatives of exponentials, and the quadratic formula matters so much for Chapter twenty-two.",
            question: "What is the name of the quadratic equation you get after substituting exponential e to the r t?",
            acceptedPhrases: ["characteristic", "auxiliary"],
            correctExplanation: "Yes. It is the characteristic equation of the differential equation.",
            remediation: "The exponential cancels out, leaving a quadratic in r. This is usually called the characteristic equation."
        ),
        Lesson(
            id: "ch22_forced",
            chapter: "Chapter 22",
            title: "Forced motion and resonance",
            explanation: "Free vibration begins with an initial disturbance and no ongoing periodic input. Forced vibration involves an external oscillating input. If a force varies sinusoidally, its angular frequency is imposed by the source and does not have to equal the natural frequency of the spring-mass system. In an undamped idealization, forcing exactly at natural frequency creates resonance, and the standard nonresonant steady-state amplitude expression has a denominator approaching zero. With damping, amplitude stays finite and the peak occurs at a frequency that can differ from the undamped natural frequency. The general solution to a forced linear equation is the sum of a complementary free-response solution and a particular forced-response solution.",
            question: "In the ideal undamped case, what do we call the condition when forcing frequency equals natural frequency?",
            acceptedPhrases: ["resonance", "resonant"],
            correctExplanation: "Correct. That is resonance in the undamped model.",
            remediation: "When external forcing matches the system natural frequency, it can build a very large response. The name is resonance."
        ),
        Lesson(
            id: "ch22_damping",
            chapter: "Chapter 22",
            title: "Damping regimes",
            explanation: "Damping is resistance that removes energy from motion. A common mathematical model uses a force proportional to velocity and opposite its direction. In the equation m x double dot plus c x dot plus k x equals zero, c is the viscous damping coefficient. The critical damping coefficient is two times the square root of m times k. When actual damping c is less than critical damping, the system is underdamped and oscillates with a decaying envelope. At critical damping, it returns without oscillating at the boundary between the regimes. Above critical damping, it is overdamped and does not oscillate. For an underdamped system, damped angular frequency equals natural angular frequency times square root of one minus damping ratio squared.",
            question: "If the damping coefficient is below its critical value, is the system underdamped or overdamped?",
            acceptedPhrases: ["underdamped", "under damped", "light damping"],
            correctExplanation: "Right. Under critical damping, oscillations remain but decay in amplitude.",
            remediation: "Below critical means not enough damping to remove oscillations. The solution oscillates inside a decaying exponential envelope: underdamped."
        ),
        Lesson(
            id: "ch22_forced_damped",
            chapter: "Chapter 22",
            title: "Damped forced amplitude",
            explanation: "A real forced vibration often includes both an external periodic force and a damping force. For a single-degree-of-freedom mass-spring-damper, the equation is m times x double dot plus c times x dot plus k times x equals F zero times sine of driving angular frequency times time. The full solution is a transient complementary term plus a steady-state particular term. The steady-state displacement amplitude equals F zero divided by the square root of the quantity k minus m omega squared, squared, plus c omega squared. As a check, if damping is zero and the forcing frequency approaches the natural frequency, the denominator approaches zero in the ideal model. If damping is positive, the amplitude remains finite.",
            question: "In damped forced motion, which part of the general solution normally remains after the transient has decayed?",
            acceptedPhrases: ["steady", "particular", "forced response"],
            correctExplanation: "Correct. The particular, steady-state forced response remains after the transient decays.",
            remediation: "The complementary solution reflects free motion and typically decays due to damping. The lasting periodic motion is the particular steady-state response."
        ),
    ]
}
