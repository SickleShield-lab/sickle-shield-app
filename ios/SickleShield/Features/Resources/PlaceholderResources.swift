import Foundation

/// Fallback content shown when the backend `resource/all` table is empty
/// (nobody has seeded real articles yet). IDs are prefixed so
/// `ResourceDetailView` knows to skip the network fetch for these rather
/// than showing a spurious 404 error under otherwise-fine placeholder text.
enum PlaceholderResources {
    static let placeholderIDPrefix = "placeholder-"

    static let all: [EduResource] = [
        EduResource(
            id: placeholderIDPrefix + "1",
            resourceImages: [],
            title: "Understanding Sickle Cell Crises",
            subTitle: "What happens during a vaso-occlusive episode, and why",
            description: """
            A sickle cell crisis (vaso-occlusive episode) happens when sickle-shaped red blood cells block blood flow in small vessels, causing pain, tissue strain, and reduced oxygen delivery.

            Common triggers include dehydration, cold temperatures, infection, high altitude, and physical or emotional stress. Episodes can range from mild to severe and typically build up gradually before peaking.

            Tracking your own triggers and early symptoms - like the ones you log in this app - can help you and your care team recognize a crisis earlier and respond faster.
            """
        ),
        EduResource(
            id: placeholderIDPrefix + "2",
            resourceImages: [],
            title: "Staying Hydrated with Sickle Cell",
            subTitle: "Why water intake matters more than you'd think",
            description: """
            Dehydration makes red blood cells more likely to sickle and block blood vessels, so steady hydration is one of the simplest, most effective ways to reduce crisis risk.

            Aim for consistent water intake throughout the day rather than large amounts at once, and increase intake during exercise, hot weather, illness, or travel.

            The Hydration card on your Today tab tracks your daily glasses against a personal goal - small, steady sips add up more reliably than trying to catch up all at once.
            """
        ),
        EduResource(
            id: placeholderIDPrefix + "3",
            resourceImages: [],
            title: "Building Your Personal Pain Plan",
            subTitle: "A calm plan is easier to follow than a crisis-time decision",
            description: """
            A Personal Pain Plan is a short, written list of the steps you want to follow when a crisis starts - written while you're calm, not in the moment.

            Good plans usually cover: which medication to take and when, comfort measures like heat or rest, hydration reminders, and a clear threshold for when to call your care team or seek emergency care.

            You can write and edit yours anytime under Settings > My Pain Plan, and it's shown front-and-center inside Crisis Mode when you need it most.
            """
        ),
        EduResource(
            id: placeholderIDPrefix + "4",
            resourceImages: [],
            title: "When to Seek Emergency Care",
            subTitle: "Warning signs that go beyond a typical crisis",
            description: """
            Most crises can be managed with your usual pain plan, but some symptoms warrant emergency care right away: chest pain or difficulty breathing, fever above 101°F (38.3°C), sudden weakness or vision changes, or pain that isn't responding to your usual measures after a few hours.

            If you experience any of these, use the Emergency tab's SOS button or Crisis Mode's "Call Emergency Services" action rather than waiting it out.

            This app is informational and does not replace guidance from your care team - always follow their specific instructions for your condition.
            """
        ),
    ]
}
