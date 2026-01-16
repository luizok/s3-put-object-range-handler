layout = [
    ('_type', 1, 1),
    ("user_id", 2, 12),
    ("value", 14, 7, lambda c: float(c)),
]

layout_default_fn = []
identity_fn = lambda c: c
for col_def in layout:
    if len(col_def) == 3:
        layout_default_fn.append((*col_def, identity_fn))
        continue

    layout_default_fn.append(col_def)

print(layout)
print(layout_default_fn)
