module Codenamize

export codenamize, codenamize_particles

include("constants.jl")

function replace_nothing(x, r)
   x[x .== nothing] .= r
   x
end

get_length_positions(x, max_length) =
    replace_nothing(indexin(1:max_length, map(length, x)), length(x))

const ADJECTIVE_LENGTHS = get_length_positions(ADJECTIVES, 20)
const NOUN_LENGTHS = get_length_positions(NOUNS, 20)

function codenamize_particles(obj; adjectives=1, max_item_chars=Inf,
                              hash_algo=hash)
    """
    Returns an array a list of consistent codenames for the given object,
    by joining random adjectives and words together.

    Args:
        obj (int|string): The object to assign a codename.
        adjectives (int): Number of adjectives to use (default 1).
        max_item_chars (int): Max characters of each part of the codename.

    Changing max_item_length will produce different results for the same
    objects, so existing mapped codenames will change substantially.
    """
    # Prepare codename word lists and calculate size of codename space
    max_item_chars = Int(clamp(max_item_chars, 3, 15))
    valid_nouns = NOUNS[1:NOUN_LENGTHS[max_item_chars]]
    valid_adjs = ADJECTIVES[1:ADJECTIVES_LENGTHS[max_item_chars]]
    particles = vcat([valid_nouns], repeat([valid_adjs], adjectives))
    total_words = prod(map(length, particles))
    obj_hash = hash_algo(obj) * 36413321723440003717
    indices = accumulate(÷, map(length, particles);
                         init=obj_hash % total_words)
    reverse([p[i % length(p)] for (p, i) in zip(particles, indices)])
end

function codenamize(obj; sep="-", case=lowercase, kwargs...):
    """
    Returns a consistent codename for the given object, by joining random
    adjectives and words together.

    Args:
        obj (int|string): The object to assign a codename.
        adjectives (int): Number of adjectives to use (default 1).
        max_item_chars (int): Max characters of each part of the codename.
        sep: (string) Stromg used to join codename parts (default "-").
        case (function): Apply this function to each particle before joining;
          typically either lowercase or titlecase.

    Changing max_item_length will produce different results for the same
    objects, so existing mapped codenames will change substantially.
    """
    particles = codenamize_particles(obj; kwargs...)
    cased = map(case, particles)
    join(cased, sep)
end

end
